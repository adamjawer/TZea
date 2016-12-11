//
//  CDTweet+CoreDataProperties.swift
//  TZea
//
//  Created by Adam Jawer on 12/10/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation
import CoreData


extension CDTweet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTweet> {
        return NSFetchRequest<CDTweet>(entityName: "CDTweet");
    }

    @NSManaged public var createdDate: NSDate?
    @NSManaged public var json: NSData?
    @NSManaged public var tweetId: Int64
    @NSManaged public var userId: Int64

}
