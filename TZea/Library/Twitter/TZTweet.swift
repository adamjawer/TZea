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
    
    init(withJson: JSON) {
        json = withJson
    }
    
    func userId() -> String? {
        return json["user"]["id"].string
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

