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
    
    /*
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
    */
    
    func getUserInfo(forSession session: TWTRSession, completion: @escaping ((Dictionary<String, Any>?, Error?)->())) {
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
                }
            } catch let error as NSError {
                completion(nil, error)
            }
            
            
            //(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
        }

    }
    
    func getTweetsForSessionUser() {
        let userId = currentTwitterSession?.userID
        let client = TWTRAPIClient(userID: userId)
        
        var error: NSError?
        
        let endPoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        
        var parameters = Dictionary<String, String>()
        
        
        parameters["user_id"] = userId!
//        parameters["count"] = "20"
//        parameters["exclude_replies"] = "true"
        parameters["trim_user"] = "true"
        
        let request = client.urlRequest(withMethod: "GET",
                                        url: endPoint,
                                        parameters: parameters,
                                        error: &error)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            guard data != nil else {
                print("Error with urlRequest")
                return
            }
            
            do {
                if let data = data {
                    let rawJsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let jsonResult = rawJsonResult as? [Dictionary<String, Any>] {
                        
                        for tweet in jsonResult {
                            // get the text of the tweet
                            if let text = tweet["text"] {
                                print(text)
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
            
        }
    }
}













