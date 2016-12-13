//
//  DisplayImageViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/13/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class DisplayImageViewController: UIViewController {

    var tweet: CDTweet!
    var downloadMediaImageTask: URLSessionDownloadTask?
    
    @IBOutlet weak var mediaImageView: UIImageView!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displayImage()
    }

    func displayImage() {
        guard tweet != nil else { return }
        
        if let data = tweet.json {
            let tzTweet = TZTweet(withNSData: data)
            
            
            if let mediaURL = tzTweet.json["extended_entities"]["media"][0]["media_url_https"].string,
                let type = tzTweet.json["extended_entities"]["media"][0]["type"].string,
                let url = URL(string: mediaURL) {
                if type == "photo" {
                    
                    downloadMediaImageTask = ImageCache.sharedInstance().getCachedImage(forUrl: url) { (image, error) in
                        self.downloadMediaImageTask = nil
                        
                        guard error == nil, image != nil else {
                            print("Error getting media image")
                            return
                        }
                        
                        self.mediaImageView.image = image
                    }
                    
                }
            }
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

}

