//
//  UserTweetsViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class UserTweetsViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdentifierLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get user info for current user
        userNameLabel.text = ""
        userIdentifierLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // are we logged in?
        if TwitterHelper.sharedInstance().currentTwitterSession == nil {
            performSegue(withIdentifier: "ShowLoginView", sender: nil)
        } else {
            getUserInfo()
        }
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        TwitterHelper.sharedInstance().signOutOfTwitter()
        
        performSegue(withIdentifier: "ShowLoginView", sender: nil)
    }
    
    private func getUserInfo() {
        if let session = TwitterHelper.sharedInstance().currentTwitterSession {
            
            userIdentifierLabel.text = "@\(session.userName)"
            
            TwitterHelper.sharedInstance().getCurrentUserImage { (image, name, error) in
                guard error == nil else {
                    print("Error getting image: \(error)")
                    return
                }
                
                self.userNameLabel.text = name
                self.userImageView.image = image
            }
        } else {
            // TODO: - replace with "Generic User Image"
            userImageView.image = nil

            userNameLabel.text = ""
            userIdentifierLabel.text = ""
        }
    }
}
