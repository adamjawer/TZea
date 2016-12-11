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
typealias TwitterHelperJSONResult = (JSON?, Error?)->()
typealias TwitterHelperGetUserResult = (TWTRUser?, Error?)->()


enum TwitterHelperError: Error {
    case imageJsonError
    case invalidJsonError
    case badImageData
    case noData(Error?)
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
    
    struct TwitterEndpoint {
        static let getUserTimeline = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        static let postStatusUpdate = "https://api.twitter.com/1.1/statuses/update.json"
        static let getUser = "https://api.twitter.com/1.1/users/show.json"
    }

    func callTwitterApi(httpMethod: String,
                        endPoint: String,
                        parameters: Dictionary<String, String>,
                        completion: @escaping TwitterHelperJSONResult) {
        
        let client = TWTRAPIClient(userID: currentTwitterSession!.userID)
        var error: NSError?
        let request = client.urlRequest(withMethod: httpMethod,
                                        url: endPoint,
                                        parameters: parameters,
                                        error: &error)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            guard data != nil else {
                completion(nil, TwitterHelperError.noData(error))
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
    
    
    func getSessionUserInfo(completion: @escaping TwitterHelperJSONResult) {
        callTwitterApi(httpMethod: "GET",
                       endPoint: TwitterEndpoint.getUser,
                       parameters: ["user_id": currentTwitterSession!.userID],
                       completion: completion)
    }
    
    typealias TwitterHelperGetTweetResult = ([TZTweet]?, Error?)->()
    
    private func getClient(forSession session: TWTRSession) -> TWTRAPIClient {
        let userId = session.userID
        return TWTRAPIClient(userID: userId)
    }
    
    func getUserTweets(completion: @escaping TwitterHelperGetTweetResult) {
        callTwitterApi(httpMethod: "GET",
                       endPoint: TwitterEndpoint.getUserTimeline,
                       parameters: ["user_id": currentTwitterSession!.userID,
                                    "count": "20"]) { (json, error) in
                                        
                                        guard error == nil, json != nil else {
                                            completion(nil, error)
                                            return
                                        }
         
                                        var tweets = [TZTweet]()
                                        
                                        for (_, tweetJson):(String, JSON) in json! {
                                            tweets.append(TZTweet(withJson: tweetJson))
                                        }
                                        
                                        completion(tweets, nil)
        }
    }
    
    
    func post(statusText status: String, completion: @escaping TwitterHelperJSONResult) {
        let client = getClient(forSession: currentTwitterSession!)
        var error: NSError?
        var parameters = Dictionary<String, String>()
        
        parameters["status"] = status
   
        let request = client.urlRequest(withMethod: "POST",
                                        url: TwitterEndpoint.postStatusUpdate,
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




















