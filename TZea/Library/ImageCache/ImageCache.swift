//
//  ImageCache.swift
//  TZea
//
//  Created by Adam Jawer on 12/9/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation
import UIKit

typealias GetImageResult = (UIImage?, Error?)->()

private var _imageCache = ImageCache()

class ImageCache {
 
    class func sharedInstance() -> ImageCache {
        return _imageCache
    }
 
    private lazy var cacheOfImages = Dictionary<URL, UIImage>()
    
    func getCachedImage(forUrl url: URL, completion: @escaping GetImageResult) -> URLSessionDownloadTask? {
        
        // Does this image exist in the cache already?
        
        var image: UIImage?
        
        // (imageCache is a shared resource)
        CriticalSection(lock: self) {
            image = cacheOfImages[url]
        }
        
        // if we have an image, send it to the completion handler and exit
        if image != nil {
            
            // Send the image to the caller
            OperationQueue.main.addOperation {
                completion(image, nil)
            }
            
            return nil
        }
        
        // Image does not exist so let's try to download it
        let downloadTask = getImage(url: url) { (image, error) in
            guard error == nil, image != nil else {
                completion(nil, error)
                return
            }
            
            // Add the image to the cache
            CriticalSection(lock: self) {
                self.cacheOfImages[url] = image
            }
            
            OperationQueue.main.addOperation {
                completion(image, nil)
            }
        }
        
        // give the download task back to the caller in case they want to cancel it
        return downloadTask
    }
    
    
    func getImage(url: URL, completion: @escaping GetImageResult) -> URLSessionDownloadTask {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (fileUrl, response, error) in
            guard let fileUrl = fileUrl else {
                OperationQueue.main.addOperation {
                    completion(nil, error)
                }
                return
            }
            
            // got some data
            do {
                let data = try Data(contentsOf: fileUrl)
                
                if let image = UIImage(data: data) {
                    completion(image, nil)
                } else {
                    completion(nil, TwitterHelperError.badImageData)
                }
            } catch let error {
                // error reading the file, pass that up to the handler
                OperationQueue.main.addOperation {
                    completion(nil, error)
                }
                
            }
        }
        
        task.resume()
        
        return task
    }
    
}

// convenience function to lock critical section resources
func CriticalSection(lock: AnyObject, _ body: (()->())) {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    
    body()
}

