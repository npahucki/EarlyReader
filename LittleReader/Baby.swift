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

    /// Populates all the word sets for the baby, returning the number of sets added.
    /// Note, if word sets already exist, they will not be created again, but they will be filled
    /// The numberOfWordSetsCreated only returns new sets created, not any ecisting ones that were filled, thus a return value of zero
    /// doen't necessarily mean something when wrong. Check the value of error to see if something went wrong. 
    func populateWordSets(numberOfWordSets : Int, numberOfWordsPerSet : Int) -> (numberOfWordSetsCreated: Int, error: NSError?) {
        var setsCreated = 0
        var error : NSError? = nil
        if let ctx = managedObjectContext {
            // If any word sets are missing, populate them
            var countOfWordSets = self.wordSets.count
            if(countOfWordSets < numberOfWordSets) {
                let numberOfWordSetsToCreate = numberOfWordSets - countOfWordSets
                let entityDescripition = NSEntityDescription.entityForName("WordSet", inManagedObjectContext:ctx)
                for(var i = 0; i<numberOfWordSetsToCreate; i++) {
                    let wordSet = WordSet(entity: entityDescripition!, insertIntoManagedObjectContext: ctx)
                    wordSet.number = countOfWordSets + i
                    wordSet.baby = Baby.currentBaby!
                    setsCreated++
                }
            }
            
            for object in self.wordSets {
                let wordSet = object as WordSet
                var fillResult = wordSet.fill(numberOfWordsPerSet)
                if fillResult.numberOfWordsAdded < numberOfWordsPerSet {
                    // TODO: this probably means that we are running out of words
                    // we may need to send an alert, or signal an error.
                    NSLog("WARNING: Did not completely fill word set %@. Added %d of %d words",wordSet.number,fillResult.numberOfWordsAdded,numberOfWordsPerSet)
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

    /// Finds and returns the next WordSet that should be used to show to this baby. 
    /// May return nil and no error if there are no word sets defined for this baby.
    func findNextWordSetToShow() -> (wordSet: WordSet?, error : NSError?) {
        var error: NSError? = nil
        var set : WordSet? = nil
        
        if let ctx = self.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "WordSet")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "(baby == %@)",self)
            if let results = ctx.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
                set = results.first
            }
        }
        
        return (wordSet: set, error: error)
    }
    
    
}
