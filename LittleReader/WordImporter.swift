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
        
        
        let words = wordList.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        // Sort words ascending
        
        if let entityDescripition = NSEntityDescription.entityForName("Word", inManagedObjectContext:_managedContext) {
            var wordsThatAlreadyExistIdx = 0
            // First get a list of existing words
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = entityDescripition
            fetchRequest.predicate = NSPredicate(format:"(text IN %@)", words);
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")]
            fetchRequest.propertiesToFetch = ["text"]
            let wordsThatAlreadyExist = _managedContext.executeFetchRequest(fetchRequest, error: &error) as [Word]
            
            // Now insert words that don't already exist
            if(error == nil) {
                for w in words {
                    if !w.isEmpty {
                        if wordsThatAlreadyExist.count > 0 &&
                            w.localizedCaseInsensitiveCompare(wordsThatAlreadyExist[wordsThatAlreadyExistIdx].text) == NSComparisonResult.OrderedSame {
                            // Skip, already eixts
                            wordsThatAlreadyExistIdx++
                            NSLog("Skipped import of %@ because it already exists", w)
                        } else {
                            count++
                            let word = Word(entity: entityDescripition, insertIntoManagedObjectContext: _managedContext)
                            word.text = w
                        }
                    }
                }
                
                _managedContext.save(&error)
            }
        }
        return (numberOfWordsAdded : count, error: error)
        
    }
}
