//
//  UserTweetsTweetCell.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class UserTweetsTweetCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!        
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var attachmentHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyCountLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var downloadImageTask: URLSessionDownloadTask?
    var downloadMediaImageTask: URLSessionDownloadTask?
    
    func configure(withTweet tweet: CDTweet) {
        
        downloadImageTask?.cancel()
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
            
            userNameLabel.text = tzTweet.userName()
            
            screenNameLabel.text = tzTweet.screenName()
            
            dateLabel.text = tzTweet.formattedTweetDate()
            
            tweetTextLabel.attributedText = tzTweet.text(formattedFor: .list)

            if let mediaURL = tzTweet.json["extended_entities"]["media"][0]["media_url_https"].string,
                let type = tzTweet.json["extended_entities"]["media"][0]["type"].string,
                let url = URL(string: mediaURL) {
                if type == "photo" {

                    self.attachmentHeightConstraint.constant = 143
                    
                    downloadMediaImageTask = ImageCache.sharedInstance().getCachedImage(forUrl: url) { (image, error) in
                        guard error == nil, image != nil else {
                            print("Error getting media image")
                            return
                        }
                        
                        self.attachmentImageView.image = image
                    }
                    
                }
            } else {
                attachmentHeightConstraint.constant = 0
            }
            
            if let url = tzTweet.userProfileUrl() {
                downloadImageTask = ImageCache.sharedInstance().getCachedImage(forUrl: url) { (image, error) in
                    
                    guard error == nil, image != nil else {
                        self.userImageView.image = UIImage(named: "BrokenImage")
                        return
                    }
                    
                    self.userImageView.image = image
                }
            } else {
                userImageView.image = UIImage(named: "NoUserImage")
            }
        }
    }
    
}
