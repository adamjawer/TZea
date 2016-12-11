//
//  TZTweet.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TZTweet {
    var json: JSON
    
    init(withJson json: JSON) {
        self.json = json
    }
    
    init(withData data: Data) {
        self.json = JSON(data: data)
    }
    
    init(withNSData data: NSData) {
        let data = Data.init(referencing: data)
        self.json = JSON(data: data)
    }
    
    func getJsonAsData() -> Data? {
        do {
            let data = try json.rawData()
            return data
        } catch {
            return nil
        }
    }
    
    func getJsonAsNSData() -> NSData? {
        do {
            let data = try json.rawData()
            let nsData = NSData(data: data)
            
            return nsData
        } catch {
            return nil
        }
        
        
    }
    
    func userId() -> Int64 {
        return json["user"]["id"].int64Value
    }
    
    func tweetId() -> Int64 {
        return json["id"].int64Value
    }
    
    func userName() -> String? {
       return json["user"]["name"].string
    }
    
    func screenName() -> String? {
        return json["user"]["screen_name"].string
    }
    
    func createdDate() -> Date? {
//        Sat Oct 25 14:05:58 +0000 2014
        if let dateString = json["created_at"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            
            return formatter.date(from: dateString)
        } else {
            return nil
        }
    }
    
    func tweetTimeStamp() -> String? {
        if let date = createdDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a Z"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    func formattedTweetDate() -> String? {
        if let date = createdDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            return dateFormatter.string(from: date)
        } else {
            return "xxxxxx"
        }
    }
    
    func text() -> String? {
        return json["text"].string
    }
    
    func userProfileUrl() -> URL? {
        if let urlString = json["user"]["profile_image_url_https"].string {
            return URL(string: urlString)
        } else {
            return nil
        }
    }
}

extension JSON {
    public var date: NSDate? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str) as NSDate?
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        // TODO: - Fix This!
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        fmt.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        return fmt
    }()
}

