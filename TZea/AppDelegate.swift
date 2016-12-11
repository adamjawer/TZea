//
//  AppDelegate.swift
//  TZea
//
//  Created by Adam Jawer on 12/6/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    
    // MARK: - App Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Twitter.sharedInstance().start(withConsumerKey: "jjYEc7o8G14q6nBQHgNYlVVNb", consumerSecret: "TqZleyy69YNTpJETteqsll7kdJBYquqoJaLi2tXQnnTSi5fDig")
        Fabric.with([Twitter.self, Crashlytics.self])
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveMainContext()
    }
    
    // MARK: - Helpers
    
    private func setRootViewController(forIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        window?.rootViewController = viewController
        
        // give it the Core Data Stack
        if let navController = viewController as? UINavigationController,
            let userTweetsController = navController.viewControllers.first as? UserTweetsViewController {
            
            userTweetsController.coreDataStack = coreDataStack
        }
        
        TwitterHelper.sharedInstance().coreDataStack = coreDataStack
    }
    
    private struct StoryboardIdentifier {
        static let userTweetsView = "UserTweetsNavController"
        static let launchView = "LaunchView"
    }
    
    func switchToUserTweetsView() {
        setRootViewController(forIdentifier: StoryboardIdentifier.userTweetsView)
    }
    
    func switchToLaunchView() {
        setRootViewController(forIdentifier: StoryboardIdentifier.launchView)
    }
    
}

