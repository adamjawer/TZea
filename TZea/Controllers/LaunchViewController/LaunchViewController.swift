//
//  LaunchViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/10/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import TwitterKit

class LaunchViewController: UIViewController {

    @IBAction func loginWithTwitter(_ sender: UIButton) {
        loginWith(method: .all)
    }
    
    @IBAction func addAcount(_ sender: UIButton) {
        loginWith(method: .webBased)
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
        
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.switchToUserTweetsView()
        }
    }

}
