//
//  CoreDataTestTableViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/10/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTestTableViewController: UITableViewController {

    var coreDataStack: CoreDataStack!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var _fetchedResultsController: NSFetchedResultsController<CDTweet>? = nil
    var fetchedResultsController: NSFetchedResultsController<CDTweet> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<CDTweet>(entityName: "CDTweet")
        
        fetchRequest.fetchBatchSize = 20

        let userId = TwitterHelper.sharedInstance().currentTwitterSession!.userID
        let predicate = NSPredicate(format: "userId = %@", userId)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "tweetId", ascending: false)
        
        // no sort descriptor for now
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Master")
        
//        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)

        let tweet = self.fetchedResultsController.object(at: indexPath)
        
        if let data = tweet.json {
            let tzTweet = TZTweet(withNSData: data)
            
            cell.textLabel?.text = tzTweet.text()
            cell.detailTextLabel?.text = "TweetId: \(tzTweet.tweetId())"
        }
                
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
    }    
}
