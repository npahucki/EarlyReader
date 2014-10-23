//
//  Baby.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData
import UIKit


@objc(Baby)
class Baby: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var birthDate: NSDate
    @NSManaged var wordSets: NSSet
    
    class var currentBaby : Baby? {
        set(baby) {
            if let b = baby {
                assert(!b.objectID.temporaryID, "You should only set babies that have already been saved as current baby")
                NSUserDefaults.standardUserDefaults().setURL(b.objectID.URIRepresentation(), forKey: "currentBabyUrl")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("currentBabyUrl")
            }
        }
        get {
            var baby : Baby? = nil
            
            if let currentBabyUrl = NSUserDefaults.standardUserDefaults().URLForKey("currentBabyUrl") {
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                if let ctx = appDelegate.managedObjectContext {
                    if let coordinator = ctx.persistentStoreCoordinator {
                        if let objectId = coordinator.managedObjectIDForURIRepresentation(currentBabyUrl) {
                            var error : NSError? = nil
                            if let err = error {
                                UsageAnalytics.trackError("Error trying to find current baby", error: err)
                            } else {
                                baby = ctx.existingObjectWithID(objectId, error: &error) as Baby?
                            }
                        }
                    }
                }
            }
            return baby;
        }
    }
    
    
}
