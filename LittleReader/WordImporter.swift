//
//  WordImporter.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/27/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

class WordImporter {
    
    
    private let _managedContext : NSManagedObjectContext
    
    init(managedContext : NSManagedObjectContext) {
        self._managedContext = managedContext
    }
    
    
    func importWords(wordList : [String]) -> (numberOfWordsAdded : Int, error : NSError?) {
        var count = 0
        var error: NSError? = nil
        
        
        // Sort words ascending, trim words
        let words = wordList
            .map{ $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        
            var wordsThatAlreadyExistIdx = 0
            // First get a list of existing words
             let fetchRequest = NSFetchRequest(entityName: "Word")
            fetchRequest.predicate = NSPredicate(format:"(text IN %@)", words);
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")]
            fetchRequest.propertiesToFetch = ["text"]
            let wordsThatAlreadyExist = _managedContext.executeFetchRequest(fetchRequest, error: &error) as [Word]?
        
            for w in words {
                if !w.isEmpty {
                    var currentExistingWord : String? = wordsThatAlreadyExist?.count > 0 ? wordsThatAlreadyExist![wordsThatAlreadyExistIdx].text : nil
                    if currentExistingWord != nil && w.localizedCaseInsensitiveCompare(currentExistingWord!) == NSComparisonResult.OrderedSame {
                        // Skip, already eixts
                        wordsThatAlreadyExistIdx++
                        NSLog("Skipped import of %@ because it already exists", w)
                    } else {
                        if let entityDescription = NSEntityDescription.entityForName("Word", inManagedObjectContext:_managedContext) {
                            count++
                            let word = Word(entity: entityDescription, insertIntoManagedObjectContext: _managedContext)
                            word.text = w
                        }
                    }
                }
            }
        
            // Now insert words that don't already exist
            if(error == nil) {
                _managedContext.save(&error)
            }
        return (numberOfWordsAdded : count, error: error)
        
    }
}
