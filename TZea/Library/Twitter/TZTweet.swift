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
    
    func userName() -> String {
       return json["user"]["name"].stringValue
    }
    
    func screenName() -> String {
        return "@" + json["user"]["screen_name"].stringValue
    }
    
    func createdDate() -> Date? {
        //  Twitter JSON date string is formatted like this: "Sat Oct 25 14:05:58 +0000 2014"
        if let dateString = json["created_at"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            
            return formatter.date(from: dateString)
        } else {
            return nil
        }
    }
    
    func tweetDetailTimeStamp() -> String {
        if let date = createdDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy, h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func formattedDetailTweetTimeString() -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
        let attributes: [String : Any] = [NSFontAttributeName: font,
                                          NSForegroundColorAttributeName: UIColor.defaultStatus()]
        let attributedString = NSMutableAttributedString(
            string: tweetDetailTimeStamp(),
            attributes: attributes)
        
        let placeName = locationPlaceName()
        if placeName.characters.count > 0 {
            let attributes: [String : Any] = [NSFontAttributeName: font,
                                              NSForegroundColorAttributeName: UIColor.inlineHighlight()]
            let locationAttributedString = NSAttributedString(string: " \(placeName)", attributes: attributes)
            
            attributedString.append(locationAttributedString)
        }
        
        return attributedString
    }
    
    func locationPlaceName() -> String {
        return json["place"]["full_name"].stringValue
    }
    
    func tweetTimeStamp() -> String {
        if let date = createdDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a Z"
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func formattedTweetDate() -> String {
        if let date = createdDate() {
            // how many seconds ago?
            let s = Int(floor(fabs(date.timeIntervalSinceNow)))
            
            if s < 60 {
                return "(\(s)s"
            }
            
            let m = s / 60
            
            if m < 60 {
                return "\(m)m"
            }
            
            let h = m / 60
            
            if h < 24 {
                return "\(h)h"
            }
            
            let d = h / 24
            
            if d < 7 {
                return "\(d)d"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func isRetweeted() -> Bool {
        return json["retweeted"].boolValue
    }
    
    func text() -> String {
        // The retweet is giving me some issues. Which text do I display?
        // When Retweeted, the default text is prepended with "RT ". 
        // The entity indicies are congruent with the extra characters
        // However, the "retweeted_status" dictionary contains the full text of the tweet
        // This does not however seem to have proper highlight indices...
        
//        if isRetweeted() {
//            return json["retweeted_status"]["text"].stringValue
//        } else {
            return json["text"].stringValue
//        }
    }
    
    func userProfileUrl() -> URL? {
        if let urlString = json["user"]["profile_image_url_https"].string {
            return URL(string: urlString)
        } else {
            return nil
        }
    }
    
    func text(formattedFor destination: TweetFormatDestination) -> NSAttributedString? {
        let font: UIFont
        switch  destination {
        case .list:
            font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        case .detail:
            font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        }
        
        
        let attributes: [String : Any] = [NSFontAttributeName: font,
                                          NSForegroundColorAttributeName: UIColor.defaultStatus()]
        
        let attributedString = NSMutableAttributedString(string: text(), attributes: attributes)
        
        // add entity highlights
        func highlight(entities: JSON) {
            let count = entities.count
            
            for i in 0..<count {
                if let start = entities[i]["indices"][0].int,
                    let end = entities[i]["indices"][1].int {
                    attributedString.addAttribute(NSForegroundColorAttributeName,
                                                  value: UIColor.inlineHighlight(),
                                                  range: NSMakeRange(start, end - start))
                    
                }
            }
        }
        
        highlight(entities: json["entities"]["symbols"])
        highlight(entities: json["entities"]["user_mentions"])
        highlight(entities: json["entities"]["urls"])
        highlight(entities: json["entities"]["hashtags"])
        
        return attributedString
    }
    
}

enum TweetFormatDestination {
    case list
    case detail
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

