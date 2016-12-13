//
//  TweetDetailViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/11/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    var coreDataStack: CoreDataStack!
    var tweet: CDTweet!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Tweet"
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImage" {
            if let controller = segue.destination as? DisplayImageViewController {
                
                controller.tweet = tweet
            }
        }
    }
}

extension TweetDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetDetailCell", for: indexPath) as! TweetDetailTableViewCell
        
        cell.configureCell(withTweet: tweet)
        
        return cell
    }
}
