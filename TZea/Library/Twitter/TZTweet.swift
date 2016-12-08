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
    
    func userName() -> String? {
       return json["user"]["name"].string
    }
    
    func screenName() -> String? {
        return json["user"]["screen_name"].string
    }
    
    func createdDate() -> Date? {
        return json["created_at"].date as Date?
    }
    
    func formattedTweetDate() -> String? {
        return "m/d/yy"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        if let date = createdDate() {
//            return dateFormatter.string(from: date)
//        } else {
//            return nil
//        }
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
