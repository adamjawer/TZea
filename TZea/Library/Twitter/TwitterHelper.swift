//
//  TwitterHelper.swift
//  TZea
//
//  Created by Adam Jawer on 12/6/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation
import Accounts
import TwitterKit

private var _twitterHelper = TwitterHelper()

class TwitterHelper {
    
    var currentTwitterSession: TWTRSession?
    
    class func sharedInstance() -> TwitterHelper {
        return _twitterHelper
    }
    
    /**
     Returns an array of ACAccount objects for every Twitter account in the system Account Store
     */
    class func getTwitterAccounts() -> [ACAccount] {
        if let accounts = ACAccountStore().accounts as? [ACAccount] {
            return accounts.filter { $0.accountType.identifier == ACAccountTypeIdentifierTwitter }
        } else {
            return []
        }
    }
    
    class func hasPersistedTwitterAccounts() -> Bool {
        return self.getTwitterAccounts().count > 0
    }
}
