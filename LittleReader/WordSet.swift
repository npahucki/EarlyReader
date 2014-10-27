//
//  WordSet.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData


@objc(WordSet)
class WordSet: NSManagedObject {

    @NSManaged var number: NSNumber
    @NSManaged var lastViewedOn: NSDate
    @NSManaged var words: NSMutableSet
    @NSManaged var baby: Baby

    
    /// Makes sure the word set is filled with the number of words per wordset
    /// This method does NOT save the context.
    ///
    /// :param: numberOfWords The number of worrds to fill the word set with
    /// :returns: A tuple, with the number of words added to the set (possibly 0 or less than requested)  and an error (if any)
    func fill(numberOfWords : Int) -> (numberOfWordsAdded : Int , error: NSError?) {
        var count = 0
        var error : NSError? = nil;

        let numberOfWordsNeeded = numberOfWords - words.count;
        if numberOfWordsNeeded > 0 {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "wordSet = NULL AND retiredOn = NULL", argumentArray: nil)
            fetchRequest.fetchLimit = numberOfWordsNeeded
            if let words = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as? [Word] {
                for word in words {
                    self.words.addObject(word)
                    word.wordSet = self;
                    word.activatedOn = NSDate()
                }
                count = words.count
            }
        }
        
        return (numberOfWordsAdded : count, error : error)
    }
    
    /// Removes any words that have been viewed the maximum number of times
    /// then fills the set to the number of words it had before the removal
    func retireOldWords() -> (numberOfWordsRetired : Int, error : NSError?) {
        var wordsRetired = 0
        let now = NSDate()
        let wordsInSet = self.words.count
        for object in self.words {
            if let word = object as? Word {
                if word.timesViewed >= WORD_VIEWS_BEFORE_RETIREMENT {
                    word.retiredOn = NSDate()
                    word.wordSet = nil;
                    wordsRetired++
                }
            }
        }
    
        assert(self.words.count == wordsInSet - wordsRetired, "Words not removed from set as expected")
        
        // Replace the removed words with new ones
        return (numberOfWordsRetired : wordsRetired, error : nil);
    }
    
}
