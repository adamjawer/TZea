//
//  ViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/6/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    @IBAction func loginWithTwitter(_ sender: UIButton) {
        loginWith(method: .all)
    }
    
    func loginWith(method: TWTRLoginMethod) {
        Twitter.sharedInstance().logIn(withMethods: method) { (session, error) in
            if let session = session {
                self.loggedIn(withSession: session)
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
    }

    
    func loggedIn(withSession session: TWTRSession) {
        // set the current session
        TwitterHelper.sharedInstance().currentTwitterSession = session
        
        // tell the appdelegate to switch to the UserTweetsView
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchToUserTweetsView()
    }

}

