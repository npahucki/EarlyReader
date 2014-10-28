//
//  WordSet.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData


class WordSet: NSManagedObject {

    @NSManaged var number: NSNumber
    @NSManaged var lastViewedOn: NSDate?
    @NSManaged var lastWordRetiredOn: NSDate?
    @NSManaged var words: NSMutableSet
    @NSManaged var baby: Baby

    
    /// Makes sure the word set is filled with the default number of words per wordset
    /// This method does NOT save the context.
    ///
    /// :returns: A tuple, with the number of words added to the set (possibly 0) and an error (if any)
    func fill() -> (numberOfWordsAdded : Int , error: NSError?) {
            return fill(WORDS_PER_WORDSET)
    }
    
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


    /// Retires at most a single word, if not words in this set have been retired in the last 24 hours.
    func retireOldWord() -> (wasWordRetired : Bool, error : NSError?) {
        var wordRetired = false
        var error : NSError? = nil
        let now = NSDate()
        var shouldRetire = false
        if self.lastWordRetiredOn == nil || self.lastWordRetiredOn!.timeIntervalSinceDate(now) > TIME_INTERVAL_24_HOURS {
            let result = self.retireOldWords(1)
            error = result.error
            wordRetired = result.numberOfWordsRetired > 0
        }
        
        return (wasWordRetired : wordRetired, error : error);
    }
    
    /// Retires up to maximumWordsToRetire words that have been viewed at least WORD_VIEWS_BEFORE_RETIREMENT
    /// and returns the number of words actually retired. See also retireOldWord() which should be generally 
    /// prefered to this method.
    func retireOldWords(maximumWordsToRetire:Int) -> (numberOfWordsRetired : Int, error : NSError?) {
        var wordsRetired = 0
        let now = NSDate()
        let wordsInSet = self.words.count
        let wordsSortedByViews = self.words.sortedArrayUsingDescriptors([NSSortDescriptor(key: "timesViewed", ascending:false)]) as [Word]
        for word in wordsSortedByViews {
            if word.timesViewed >= WORD_VIEWS_BEFORE_RETIREMENT {
                self.lastWordRetiredOn = now
                word.retiredOn = now
                word.wordSet = nil;
                wordsRetired++
                if wordsRetired >= maximumWordsToRetire {
                    break
                }
            }
        }
    
        assert(self.words.count == wordsInSet - wordsRetired, "Words not removed from set as expected")
        
        // Replace the removed words with new ones
        return (numberOfWordsRetired : wordsRetired, error : nil);
    }
    
}
