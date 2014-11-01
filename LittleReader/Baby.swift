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


public class Baby: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var birthDate: NSDate
    @NSManaged public var wordSets: NSSet
    
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
                if let ctx = _mainManagedObjectContext {
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
            return baby
        }
    }

    /// Populates all the word sets for the baby, returning the number of sets added/removed to conform to the number specified.
    /// Note, if word sets already exist, they will not be created again, but they will be filled
    /// The numberOfWordSetsCreated only returns new sets created, not any existing ones that were filled, thus a return value of zero
    /// doen't necessarily mean something when wrong. Check the value of error to see if something went wrong. 
    public func populateWordSets(numberOfWordSets : Int, numberOfWordsPerSet : Int = WORDS_PER_WORDSET) -> (numberOfWordSetsCreated: Int, error: NSError?) {
        var setsCreated = 0
        var error : NSError? = nil
        if let ctx = managedObjectContext {
            // If any word sets are missing, populate them
            var countOfWordSets = self.wordSets.count
            if countOfWordSets < numberOfWordSets {
                let numberOfWordSetsToCreate = numberOfWordSets - countOfWordSets
                let entityDescripition = NSEntityDescription.entityForName("WordSet", inManagedObjectContext:ctx)
                for(var i = 0; i<numberOfWordSetsToCreate; i++) {
                    let wordSet = WordSet(entity: entityDescripition!, insertIntoManagedObjectContext: ctx)
                    wordSet.number = UInt16(countOfWordSets + i)
                    wordSet.baby = self
                    setsCreated++
                }
            } else if countOfWordSets > numberOfWordSets  {
                // need to reduce the number of sets
                let sortedWordSets = self.wordSets.sortedArrayUsingDescriptors([NSSortDescriptor(key: "number", ascending:false)]) as [WordSet]
                var setsToRemove = countOfWordSets - numberOfWordSets
                for set in sortedWordSets {
                    self.managedObjectContext?.deleteObject(set)
                    setsCreated--
                    if --setsToRemove <= 0 {
                        break
                    }
                }
            }
            
            let sortedWordSets = self.wordSets.sortedArrayUsingDescriptors([NSSortDescriptor(key: "number", ascending:true)]) as [WordSet]
            // Iterate sorted, so that we fill number 1 first, then 2, 3, etc....
            for wordSet in sortedWordSets {
                var fillResult = wordSet.fill(numberOfWordsPerSet)
                if wordSet.words.count < numberOfWordsPerSet && fillResult.numberOfWordsAdded < numberOfWordsPerSet {
                    // TODO: this probably means that we are running out of words
                    // we may need to send an alert, or signal an error.
                    NSLog("WARNING: Did not completely fill word set %d. Added %d of %d words",wordSet.number,fillResult.numberOfWordsAdded,numberOfWordsPerSet)
                } else if let e = fillResult.error {
                    // Stop here, report error
                    error = e; break
                }
            }
            
            if error == nil {
                ctx.save(&error)
            } else {
                NSLog("Rolled back word set creation due to error")
                ctx.rollback()
            }
        }
        
        return (numberOfWordSetsCreated: setsCreated, error: error)
    }
    
}
