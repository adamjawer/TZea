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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func post() {
        let store = Twitter.sharedInstance().sessionStore
        
        let sessions = store.existingUserSessions()
        if sessions.count == 0 {
            // must log in to a session
        } else {
            let session = sessions.first as? TWTRSession
            
            if let session = session {
                print(session.authToken)
                print(session.authTokenSecret)
                print(session.userID)
                print(session.userName)
                
                store.logOutUserID(session.userID)
                
                print("Logged Out")
            }
            
        }
    }

    @IBAction func loginWithTwitter(_ sender: UIButton) {
        // Are there any saved Twitter logins on this device?
        let twitterAccounts = TwitterHelper.getTwitterAccounts()
        
        if twitterAccounts.count > 0 {
        
            // YES - List them in an action sheet as follows
            
            let actionSheet = UIAlertController(title: "Select an account", message: nil, preferredStyle: .actionSheet)
            
            for account in twitterAccounts {
                
                let action = UIAlertAction(
                    title: "\(account.accountDescription!)",
                    style: .default) { (action) in
                        // log in with this account
                }
                
                actionSheet.addAction(action)
            }
            
            actionSheet.addAction(
                UIAlertAction(title: "Use a different account...",
                              style: .default) { (action) in
                                
                                
                }
            )

            actionSheet.addAction(
                UIAlertAction(title: "Cancel", style: .cancel)
            )
            
            present(actionSheet, animated: true, completion: nil)
            
            // savedTwitter1 - User Name
            // savedTwitter2 - User Name
            // Other account -
            //
            // Cancel
        } else {
            // NO - Proceed to logIn with .All method

            Twitter.sharedInstance().logIn(withMethods: TWTRLoginMethod.all) { (session, error) in
                if let session = session {
                    print("signed in as \(session.userName)");
                } else if let error = error {
                    print("error: \(error.localizedDescription)");
                }
            }

        }
    }
    
    /*
    func logoutIfNeeded() {
        let sessionStore = Twitter.sharedInstance().sessionStore
        if sessionStore.existingUserSessions().count > 0 {
            let session = sessionStore.existingUserSessions().first as! TWTRSession
            sessionStore.logOutUserID(session.userID)
        }
    }    
    
    @IBAction func testAction(_ sender: Any) {
        logoutIfNeeded()
        
        Twitter.sharedInstance().logIn(withMethods: TWTRLoginMethod.all) { (session, error) in
            if let session = session {
                print("signed in as \(session.userName)");
            } else if let error = error {
                print("error: \(error.localizedDescription)");
            }
        }
        
//        Twitter.sharedInstance().logIn { (session, error) in
//            
//            if let session = session {
//                print("signed in as \(session.userName)");
//                self.post();
//            } else if let error = error {
//                print("error: \(error.localizedDescription)");
//            }
//        }
        

    }
 */

}

