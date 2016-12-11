//
//  UserTweetsViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import CoreData

fileprivate struct Constants {
    static let tableContentOffsetY: CGFloat = 56
    static let bannerOffsetMax: CGFloat = 23
    static let profileOffsetMax: CGFloat = 56
    static let profileScaledMin: CGFloat = 0.8
    static let bannerTitleOffsetMax: CGFloat = -50
    static let headerTextAlphaOffsetMax: CGFloat = 112
}

class UserTweetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var headerView: UserTweetsHeaderView!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var bannerTitleContainer: UIView!
    @IBOutlet weak var bannerUserNameLabel: UILabel!
    @IBOutlet weak var bannerTweetCountLabel: UILabel!
    
    var coreDataStack: CoreDataStack!
    
    fileprivate var tweetsDataSource = [TZTweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = Bundle.main.loadNibNamed("UserTweetsHeaderView", owner: nil, options: nil)?.first as! UserTweetsHeaderView
        headerView.didPressConfigButton = {
            self.configButtonPressed()
        }
        
        tableView.contentInset = UIEdgeInsets(top: Constants.tableContentOffsetY, left: 0, bottom: 0, right: 0)
        
        setNeedsStatusBarAppearanceUpdate()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeTweet" {
            if let composeTweetController = segue.destination as? ComposeViewController {
                
                composeTweetController.didClose = { (didPostTweet) in
                    if didPostTweet {
                        self.refreshTweets(moveToTop: true)
                    }
                    self.dismiss(animated: true)
                }
            }
        } else if segue.identifier == "coreDataTest" {
            if let controller = segue.destination as? CoreDataTestTableViewController {
                controller.coreDataStack = coreDataStack
            }
        }
    }
    
    // MARK: - Events
    
    func configButtonPressed() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Sign out", style: .default) { (action) in
            self.signOut()
            }
        )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK - Helpers
    
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
            
             guard let tweetEntityDescription = NSEntityDescription.entity(forEntityName: "CDTweet", in: self.coreDataStack.managedObjectContext) else {
             fatalError("Unable to load entities")
             }
             
             // add these tweets to core data and update the fetched results controller
             for tzTweet in tweets! {
                // does this tweet already exist?
                if self.tweetExistsInDB(tweetId: tzTweet.tweetId()) {
                    continue
                }
                
                // add it to the database
                let tweet = CDTweet(entity: tweetEntityDescription, insertInto: self.coreDataStack.managedObjectContext)
             
                tweet.tweetId = tzTweet.tweetId()
                tweet.userId = tzTweet.userId()
                tweet.createdDate = tzTweet.createdDate()?.getSwiftNSDate()
                tweet.json = tzTweet.getJsonAsNSData()
            }
             self.coreDataStack.saveMainContext()
            
            let tweetCount = tweets!.count
            
            let pluralS: String
            if tweetCount == 1 {
                pluralS = ""
            } else {
                pluralS = "s"
            }
            self.bannerTweetCountLabel.text = "\(tweetCount) Tweet\(pluralS)"
            self.tweetsDataSource = tweets!
            self.tableView.reloadData()
        }
    }

    func tweetExistsInDB(tweetId: Int64) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTweet")
        fetchRequest.predicate = NSPredicate(format: "tweetId == \(tweetId)")
        
        var tweetCount = -1
        do {
            tweetCount = try coreDataStack.managedObjectContext.count(for: fetchRequest)
        } catch {
            print("ERROR: count failed")
        }
        
        return tweetCount == 1
        
    }
    
    // move to top means if we posted something new, we want to display it at the top
    func refreshTweets(moveToTop: Bool) {
        
        loadTweets()
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
                self.bannerUserNameLabel.text = user!.formattedScreenName
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 106
    }
}

extension UserTweetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y + Constants.tableContentOffsetY
        
        
        if offsetY <= 0 {
            bannerView.transform = CGAffineTransform.identity
            profileView.transform = CGAffineTransform.identity
            bannerTitleContainer.transform = CGAffineTransform.identity
            headerView.userNameLabel.alpha = 1
            headerView.screenNameLabel.alpha = 1
        } else {
            let bannerOffset = min(offsetY, Constants.bannerOffsetMax)
            
            bannerView.transform = CGAffineTransform.init(translationX: 0, y: -bannerOffset)
            
            let profileOffset = min(offsetY, Constants.profileOffsetMax)
            profileView.transform = CGAffineTransform.init(translationX: 0, y: -profileOffset)
            
            let percent = (offsetY / Constants.profileOffsetMax)
            let scalePercent = max(1 - percent * (1 - Constants.profileScaledMin), Constants.profileScaledMin)
            
            profileView.transform = profileView.transform.scaledBy(x: scalePercent, y: scalePercent)
            
            let headerTextAlpha = 1 - min(offsetY, Constants.headerTextAlphaOffsetMax) / Constants.headerTextAlphaOffsetMax
            headerView.userNameLabel.alpha = headerTextAlpha
            headerView.screenNameLabel.alpha = headerTextAlpha
            
            
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

extension NSDate {
    func getSwiftDate() -> Date {
        return Date(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate)
    }
}

extension Date {
    func getSwiftNSDate() -> NSDate {
        return NSDate(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate)
    }
}
