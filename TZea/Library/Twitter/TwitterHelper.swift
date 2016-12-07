//
//  TwitterHelper.swift
//  TZea
//
//  Created by Adam Jawer on 12/6/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation
import Accounts
import TwitterKit

private var _twitterHelper = TwitterHelper()

typealias TwitterHelperGetImageCallback = (UIImage?, String?, Error?)->()

enum TwitterHelperError: Error {
    case imageJsonError
}

class TwitterHelper {
    
    var currentTwitterSession: TWTRSession?
    
    class func sharedInstance() -> TwitterHelper {
        return _twitterHelper
    }
    
    func signOutOfTwitter() {
        let sessionStore = Twitter.sharedInstance().sessionStore
        if let userId = sessionStore.session()?.userID {
            sessionStore.logOutUserID(userId)
            
            currentTwitterSession = nil
        }
    }
    
    /**
     Returns an array of ACAccount objects for every Twitter account in the system Account Store
     */
    class func getTwitterAccounts() -> [ACAccount] {
        if let accounts = ACAccountStore().accounts as? [ACAccount] {
            return accounts.filter { $0.accountType.identifier == ACAccountTypeIdentifierTwitter }
        } else {
            return []
        }
    }
    
    class func hasPersistedTwitterAccounts() -> Bool {
        return self.getTwitterAccounts().count > 0
    }
    
    func getCurrentUserImage(callback: TwitterHelperGetImageCallback?) {
        if let session = currentTwitterSession {
            getUserInfo(forSession: session) { (json, error) in
                // get the imageURL from the json
                guard error == nil,
                    json != nil
                else {
                    callback?(nil, nil, error)
                    return
                }
                
                if let imageUrlString = json!["profile_image_url_https"] as? String,
                    let imageUrl = URL(string: imageUrlString) {
                    
                    let name = json!["name"] as? String
                    
                    let queue = OperationQueue()
                    
                    queue.addOperation {
                        do {
                            let data = try Data(contentsOf: imageUrl)
                            
                            OperationQueue.main.addOperation {
                                let image = UIImage(data: data)
                                
                                callback?(image, name, nil)
                            }
                        } catch let error as NSError {
                            print("Error downloading data: \(error), \(error.userInfo)")

                            callback?(nil, name, error)
                        }
                    }
                } else {
                    // Unable to get image url string from json
                    callback?(nil, nil, TwitterHelperError.imageJsonError)
                }
            }
        } else {
            // There is no current user
            callback?(nil, nil, nil)
        }
    }
    
    private func getUserInfo(forSession session: TWTRSession, completion: @escaping ((Dictionary<String, Any>?, Error?)->())) {
        let userId = session.userID
        let client = TWTRAPIClient(userID: userId)
        let endPoint = "https://api.twitter.com/1.1/users/show.json?user_id=\(userId)"
        
        var error: NSError?
        
        let request = client.urlRequest(withMethod: "GET",
                                        url: endPoint,
                                        parameters: nil,
                                        error: &error)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            
            guard data != nil else {
                print("Error with urlRequest: \(error)")
                return
            }
            
            do {
                if let data = data {
                    
                    let rawJsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let jsonResult = rawJsonResult as? Dictionary<String, Any> {
                        completion(jsonResult, nil)
                    }
                    
                    // http://pbs.twimg.com/profile_images/806259878624837632/0UNKJceK_normal.jpg
                    // https://pbs.twimg.com/profile_images/806259878624837632/0UNKJceK_normal.jpg
                }
            } catch let error as NSError {
                completion(nil, error)
            }
            
            
            //(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
        }

    }
}













