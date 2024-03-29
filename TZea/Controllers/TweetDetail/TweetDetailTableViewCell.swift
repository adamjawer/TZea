//
//  TweetDetailTableViewCell.swift
//  TZea
//
//  Created by Adam Jawer on 12/12/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import SwiftyJSON

class TweetDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var mediaImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyCountLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var downloadProfileImageTask: URLSessionDownloadTask?
    var downloadMediaImageTask: URLSessionDownloadTask?    
    
    func configureCell(withTweet tweet: CDTweet) {
        downloadProfileImageTask?.cancel()
        downloadMediaImageTask?.cancel()
        
        if let data = tweet.json {
            let tzTweet = TZTweet(withNSData: data)

            // reply
            if let _ = tzTweet.inReplyToString() {
                replyCountLabel.isHidden = false
                replyCountLabel.text = "1"
                replyButton.setImage(UIImage(named: "ReplyIconMedium"), for: .normal)
            } else {
                replyButton.setImage(UIImage(named: "ReplyIconLight"), for: .normal)
                replyCountLabel.isHidden = true
            }
            
            // retweet
            let retweetCount = tzTweet.retweetCount()
            if retweetCount > 0 {
                retweetCountLabel.isHidden = false
                retweetCountLabel.text = "\(retweetCount)"
                retweetButton.setImage(UIImage(named: "RetweetIconMedium"), for: .normal)
            } else {
                retweetButton.setImage(UIImage(named: "RetweetIconLight"), for: .normal)
                retweetCountLabel.isHidden = true
            }
            
            // Likes
            let likeCount = tzTweet.favoriteCount()
            if likeCount > 0 {
                likeCountLabel.isHidden = false
                likeCountLabel.text = "\(likeCount)"
                if tzTweet.favorited() {
                    likeButton.setImage(UIImage(named:"LikeIconRed"), for: .normal)
                } else {
                    likeButton.setImage(UIImage(named:"LikeIconMedium"), for: .normal)
                }
                
            } else {
                likeCountLabel.isHidden = true
                likeButton.setImage(UIImage(named:"LikeIconLight"), for: .normal)
            }
            
            
            // User Image
            if let url = tzTweet.userProfileUrl() {
                downloadProfileImageTask = ImageCache.sharedInstance().getCachedImage(forUrl: url) { (image, error) in
                    
                    self.downloadProfileImageTask = nil
             
                    guard error == nil, image != nil else {
                        self.profileImageView.image = UIImage(named: "BrokenImage")
                        return
                    }
                    
                    self.profileImageView.image = image
                }
            } else {
                profileImageView.image = UIImage(named: "NoUserImage")
            }

            userNameLabel.text = tzTweet.userName()
            screenNameLabel.text = tzTweet.screenName()
            
            statusLabel.attributedText = tzTweet.text(formattedFor: .detail)
            
            timeStampLabel.attributedText = tzTweet.formattedDetailTweetTimeString()
                        
            if let mediaURL = tzTweet.json["extended_entities"]["media"][0]["media_url_https"].string,
                let type = tzTweet.json["extended_entities"]["media"][0]["type"].string,
                let url = URL(string: mediaURL) {
                if type == "photo" {
                    
                    self.mediaImageViewHeightConstraint.constant = 229
                    
                    downloadMediaImageTask = ImageCache.sharedInstance().getCachedImage(forUrl: url) { (image, error) in
                        self.downloadMediaImageTask = nil
                        
                        guard error == nil, image != nil else {
                            print("Error getting media image")
                            return
                        }
                        
                        self.mediaImageView.image = image
                    }
                    
                }
            } else {
                mediaImageViewHeightConstraint.constant = 0
            }
        }
        
    }
}
