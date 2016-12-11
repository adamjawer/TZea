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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Tweet"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
