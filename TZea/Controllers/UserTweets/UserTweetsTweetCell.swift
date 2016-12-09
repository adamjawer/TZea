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

    var downloadImageTask: URLSessionDownloadTask?
    
    func configure(withTweet tweet: TZTweet) {
        
        downloadImageTask?.cancel()
        
        userNameLabel.text = tweet.userName()
        if let screenName = tweet.screenName() {
            screenNameLabel.text = "@\(screenName)"
        } else {
            screenNameLabel.text = ""
        }
        dateLabel.text = tweet.formattedTweetDate()
        tweetTextLabel.text = tweet.text()
        
        if let url = tweet.userProfileUrl() {
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
