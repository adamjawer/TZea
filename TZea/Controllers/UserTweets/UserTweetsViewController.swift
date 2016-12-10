//
//  UserTweetsViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import CoreData

class UserTweetsHeader: UIView {
    @IBOutlet weak var userBannerImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdentifierLabel: UILabel!
}

class UserTweetsViewController2: UIViewController {

    @IBOutlet weak var header: UserTweetsHeader!
    @IBOutlet weak var tableView: UITableView!
    var coreDataStack: CoreDataStack!
    
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
            
            /*
            guard let tweetEntityDescription = NSEntityDescription.entity(forEntityName: "CDTweet", in: self.coreDataStack.managedObjectContext) else {
                fatalError("Unable to load entities")
            }
            
            // add these tweets to core data and update the fetched results controller
            for tzTweet in tweets! {
                // add it to the database
            
                let tweet = CDTweet(entity: tweetEntityDescription, insertInto: self.coreDataStack.managedObjectContext)
                
                tweet.tweetId = tzTweet.tweetId()
                tweet.userId = tzTweet.userId()
                tweet.createdDate = 
            }
            
            self.coreDataStack.saveMainContext()
            */
            
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

extension UserTweetsViewController2: UITableViewDataSource, UITableViewDelegate {
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

/////////////////////////////////////

fileprivate struct Constants {
    static let tableContentOffsetY: CGFloat = 56
    static let bannerOffsetMax: CGFloat = 23
    static let profileOffsetMax: CGFloat = 56
    static let profileScaledMin: CGFloat = 0.8
    static let bannerTitleOffsetMax: CGFloat = -50
}

class UserTweetsViewController: UIViewController {
    
//    @IBOutlet weak var header: UserTweetsHeader!
    @IBOutlet weak var tableView: UITableView!
    
    // new
    var headerView: UserTweetsHeaderView!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var bannerTitleContainer: UIView!
    
    var coreDataStack: CoreDataStack!
    
    fileprivate var tweetsDataSource = [TZTweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = Bundle.main.loadNibNamed("UserTweetsHeaderView", owner: nil, options: nil)?.first as! UserTweetsHeaderView
        
        
        tableView.contentInset = UIEdgeInsets(top: Constants.tableContentOffsetY, left: 0, bottom: 0, right: 0)
        
        setNeedsStatusBarAppearanceUpdate()
        
//        // get user info for current user
//        header.userNameLabel.text = ""
//        header.userIdentifierLabel.text = ""
        
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Events
    
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
            
            /*
             guard let tweetEntityDescription = NSEntityDescription.entity(forEntityName: "CDTweet", in: self.coreDataStack.managedObjectContext) else {
             fatalError("Unable to load entities")
             }
             
             // add these tweets to core data and update the fetched results controller
             for tzTweet in tweets! {
             // add it to the database
             
             let tweet = CDTweet(entity: tweetEntityDescription, insertInto: self.coreDataStack.managedObjectContext)
             
             tweet.tweetId = tzTweet.tweetId()
             tweet.userId = tzTweet.userId()
             tweet.createdDate =
             }
             
             self.coreDataStack.saveMainContext()
             */
            
            self.tweetsDataSource = tweets!
            self.tableView.reloadData()
        }
    }
    
    private func loadBannerImage(atUrl urlString: String) {
        if let imageUrl = URL(string: urlString) {
            _ = ImageCache.sharedInstance().getCachedImage(forUrl: imageUrl) { (image, error) in
                guard error == nil, image != nil else {
                    self.bannerImageView.image = UIImage(named: "BrokenImage")
                    return
                }
                
                self.bannerImageView.image = image
            }
        } else {
            self.bannerImageView.image = UIImage(named: "NoUserImage")
        }
    }
    
    private func loadProfileImage(atUrl urlString: String) {
        
        if let imageUrl = URL(string: urlString) {
            _ = ImageCache.sharedInstance().getCachedImage(forUrl: imageUrl) { (image, error) in
                guard error == nil, image != nil else {
                    self.profileImageView.image = UIImage(named: "BrokenImage")
                    return
                }
                
                self.profileImageView.image = image
            }
        } else {
            self.profileImageView.image = UIImage(named: "NoUserImage")
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
                self.headerView.screenNameLabel.text = user!.formattedScreenName
                self.headerView.userNameLabel.text = user!.name
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
            profileImageView.image = UIImage(named: "BrokenImage")
            headerView.userNameLabel.text = ""
            headerView.screenNameLabel.text = ""
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

extension UserTweetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y + Constants.tableContentOffsetY
        
        
        if offsetY <= 0 {
            bannerView.transform = CGAffineTransform.identity
            profileView.transform = CGAffineTransform.identity
            bannerTitleContainer.transform = CGAffineTransform.identity
            print(offsetY)
        } else {
            let bannerOffset = min(offsetY, Constants.bannerOffsetMax)
            
            bannerView.transform = CGAffineTransform.init(translationX: 0, y: -bannerOffset)
            
            let profileOffset = min(offsetY, Constants.profileOffsetMax)
            profileView.transform = CGAffineTransform.init(translationX: 0, y: -profileOffset)
            
            let percent = (offsetY / Constants.profileOffsetMax)
            let scalePercent = max(1 - percent * (1 - Constants.profileScaledMin), Constants.profileScaledMin)
            
            profileView.transform = profileView.transform.scaledBy(x: scalePercent, y: scalePercent)
            
            // move other text into position in the header
            if offsetY > Constants.profileOffsetMax {
                let titleOffset = max(Constants.profileOffsetMax - offsetY, Constants.bannerTitleOffsetMax)
                
                bannerTitleContainer.transform = CGAffineTransform.init(translationX: 0, y: titleOffset)
            } else {
                bannerTitleContainer.transform = CGAffineTransform.identity
            }
        }
        
    }
}
