//
//  TZeaTests.swift
//  TZeaTests
//
//  Created by Adam Jawer on 12/6/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import XCTest
import Accounts
@testable import TZea

class TZeaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func getTwitterAccounts() -> [ACAccount] {

        if let accounts = ACAccountStore().accounts as? [ACAccount] {
            return accounts.filter { $0.accountType.identifier == ACAccountTypeIdentifierTwitter }
        } else {
            return []
        }
    }
    
    func testExample() {
        
        for account in getTwitterAccounts() {
            print("Account Description: " + account.accountDescription)
            print("Account Type - Access Granted: " + String(account.accountType.accessGranted))
            print("Account Type - acdesc: " + account.accountType.accountTypeDescription)
            print("Account Type - ID: " + account.accountType.identifier)
            print("Account ID: " + String(account.identifier))
            print("Username: " + account.username)
            print("Full name: " + account.userFullName)
            print("-----")
            print(" ")
        }
        
//        let accountStore = ACAccountStore()
//        
//        if let accounts = accountStore.accounts as? [ACAccount] {
//            
//            let twitterAccounts = accounts.filter { $0.accountType.identifier == ACAccountTypeIdentifierTwitter }
//                
//            for account in twitterAccounts {
//                
//                if account.accountType.identifier == ACAccountTypeIdentifierTwitter {
//                
//                    print("Account Description: " + account.accountDescription)
//                    print("Account Type - Access Granted: " + String(account.accountType.accessGranted))
//                    print("Account Type - acdesc: " + account.accountType.accountTypeDescription)
//                    print("Account Type - ID: " + account.accountType.identifier)
//                    print("Account ID: " + String(account.identifier))
//                    print("Username: " + account.username)
//                    print("Full name: " + account.userFullName)
//                    print("-----")
//                    print(" ")
//                    
//                }
//            }
//        }
        
    }
    
}
