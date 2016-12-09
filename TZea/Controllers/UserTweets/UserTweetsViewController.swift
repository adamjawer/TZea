//
//  UserTweetsViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class UserTweetsHeader: UIView {
    @IBOutlet weak var userBannerImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdentifierLabel: UILabel!
}

class UserTweetsViewController: UIViewController {

    @IBOutlet weak var header: UserTweetsHeader!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var tweetsDataSource = [TZTweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get user info for current user
        header.userNameLabel.text = ""
        header.userIdentifierLabel.text = ""
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // are we logged in?
        if TwitterHelper.sharedInstance().currentTwitterSession == nil {
            performSegue(withIdentifier: "ShowLoginView", sender: nil)
        } else {
            getUserInfo()
            loadTweets()
        }
    }
    
    @IBAction func configButtonPressed(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Sign out", style: .default) { (action) in
                self.signOut()
            }
        )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func signOut() {
        TwitterHelper.sharedInstance().signOutOfTwitter()
        
        performSegue(withIdentifier: "ShowLoginView", sender: nil)
    }
    
    func loadTweets() {
        TwitterHelper.sharedInstance().getTweetsForSessionUser { (tweets, error) in
            guard error == nil, tweets != nil else {
                print("Error getting tweets: \(error)")
                return
            }
            
            self.tweetsDataSource = tweets!
            self.tableView.reloadData()
        }
    }

    private func loadBannerImage(atUrl urlString: String) {
        if let imageUrl = URL(string: urlString) {
            _ = ImageCache.sharedInstance().getCachedImage(forUrl: imageUrl) { (image, error) in
                guard error == nil, image != nil else {
                    self.header.userImageView.image = UIImage(named: "BrokenImage")
                    return
                }
                
                self.header.userBannerImageView.image = image
            }
        } else {
            self.header.userBannerImageView.image = UIImage(named: "NoUserImage")
        }
    }
    
    private func loadProfileImage(atUrl urlString: String) {
        
        if let imageUrl = URL(string: urlString) {
            _ = ImageCache.sharedInstance().getCachedImage(forUrl: imageUrl) { (image, error) in
                guard error == nil, image != nil else {
                    self.header.userImageView.image = UIImage(named: "BrokenImage")
                    return
                }
                
                self.header.userImageView.image = image
            }
        } else {
            self.header.userImageView.image = UIImage(named: "NoUserImage")
        }
    }
    
    private func getUserInfo() {
        if let session = TwitterHelper.sharedInstance().currentTwitterSession {
            
            // get the userInfo
            TwitterHelper.sharedInstance().getTWTRUser(forSession: session) { (user, error) in
                
                guard error == nil, user != nil else {
                    print("Error getting user: \(error)")
                    return
                }
                
                self.header.userIdentifierLabel.text = user!.formattedScreenName
                self.header.userNameLabel.text = user!.name
                self.loadProfileImage(atUrl: user!.profileImageLargeURL)
            }
            
            TwitterHelper.sharedInstance().getUserInfo(forSession: session) { (json, error) in
                guard error == nil, json != nil else {
                    print("Error getting user info: \(error)")
                    return
                }

                if let bannerUrlString = json!["profile_banner_url"].string {
                    self.loadBannerImage(atUrl: bannerUrlString)
                }
            }
        } else {
            // TODO: - replace with "Generic User Image"
            header.userImageView.image = UIImage(named: "BrokenImage")
            header.userNameLabel.text = ""
            header.userIdentifierLabel.text = ""
        }
    }
}

extension UserTweetsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCellId", for: indexPath) as! UserTweetsTweetCell
        
        let tweet = tweetsDataSource[indexPath.row]
        
        cell.configure(withTweet: tweet)
        
        
        return cell
    }
}
