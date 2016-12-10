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
import SwiftyJSON

private var _twitterHelper = TwitterHelper()

typealias TwitterHelperGetImageResult = (UIImage?, Error?)->()
typealias TwitterHelperGetJSONResult = (JSON?, Error?)->()
typealias TwitterHelperGetUserResult = (TWTRUser?, Error?)->()
typealias TwitterHelperPostTweetResult = (JSON?, Error?)->()

enum TwitterHelperError: Error {
    case imageJsonError
    case invalidJsonError
    case badImageData
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
    
    func getTWTRUser(forSession session: TWTRSession, completion: @escaping TwitterHelperGetUserResult) {
        let userId = session.userID
        let client = TWTRAPIClient(userID: userId)
        client.loadUser(withID: userId) { (user, error) in
            completion(user, error)
        }
    }

    func getUserInfo(forSession session: TWTRSession, completion: @escaping TwitterHelperGetJSONResult) {
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

                    let json = JSON(rawJsonResult)
      
                    completion(json, nil)
                }
            } catch let error as NSError {
                completion(nil, error)
            }
        }

    }
    
    typealias TwitterHelperGetTweetResult = ([TZTweet]?, Error?)->()
    
    private func getClient(forSession session: TWTRSession) -> TWTRAPIClient {
        let userId = session.userID
        return TWTRAPIClient(userID: userId)
    }
    
    func getTweetsForSessionUser(completion: @escaping TwitterHelperGetTweetResult) {
        let client = getClient(forSession: currentTwitterSession!)
        var error: NSError?
        let endPoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        var parameters = Dictionary<String, String>()
        
        parameters["user_id"] = client.userID
//        parameters["count"] = "20"
//        parameters["exclude_replies"] = "true"
//        parameters["trim_user"] = "true"
        
        let request = client.urlRequest(withMethod: "GET",
                                        url: endPoint,
                                        parameters: parameters,
                                        error: &error)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            guard data != nil else {
                completion(nil, error)
                return
            }
            
            do {
                if let data = data {
                    let rawJsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    let json = JSON(rawJsonResult)
                    
                    var tweets = [TZTweet]()

                    for (_, tweetJson):(String, JSON) in json {
                        tweets.append(TZTweet(withJson: tweetJson))
                    }
                                        
                    completion(tweets, nil)
                    
                }
            } catch let error {
                completion(nil, error)
            }
            
        }
    }

    
    func post(statusText status: String, completion: @escaping TwitterHelperPostTweetResult) {
        let client = getClient(forSession: currentTwitterSession!)
        var error: NSError?
        let endPoint = "https://api.twitter.com/1.1/statuses/update.json"
        var parameters = Dictionary<String, String>()
        
        
        parameters["status"] = status
   
        let request = client.urlRequest(withMethod: "POST",
                                        url: endPoint,
                                        parameters: parameters,
                                        error: &error)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            guard error == nil,
                data != nil,
                let urlResponse = response as? HTTPURLResponse else {
                // some internal error trying to POST
                completion(nil, error)
                return
            }
            
            // check the return code of the call
            switch urlResponse.statusCode {
                
            case HTTPStatusCodes.successOK:
                // package response into JSON
                guard let data = data else {
                    completion(nil, TwitterHelperError.invalidJsonError)
                    return
                }
                
                do {
                    let rawJsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                    let json = JSON(rawJsonResult)
                    
                    completion(json, nil)
                } catch let error {
                    completion(nil, error)
                }
                
                // everything else is an error
            default:
                completion(nil, HTTPError.httpResponseError(urlResponse.statusCode))
            }
            
        }
        
    }
    
}




















