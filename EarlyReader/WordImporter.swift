//
//  WordImporter.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/27/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

public class WordImporter {
    
    private let _baby : Baby!
    private let _managedContext : NSManagedObjectContext!
    
    
    public init(baby : Baby) {
        assert(baby.managedObjectContext != nil,"Expected Baby to have managed object context")
        _baby = baby
        _managedContext = baby.managedObjectContext!
    }
    
    
    public func importWordListNamed(name:String, completionClosure: (error : NSError?, numberOfWordsImported: Int)->()) {
        let url = NSURL(string: "http://infantiq-earlyreader.s3.amazonaws.com/word-sets/en/\(name).txt")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                // Called on background thread
            dispatch_async(dispatch_get_main_queue(),{ () -> Void in
                var error : NSError? = error
                var numberOfWordsImported : Int = 0
                if error == nil {
                    if let wordString = NSString(data:data, encoding: NSUTF8StringEncoding) {
                        if let wordArray = self.parseWords(wordString) {
                            let result = self.importWords(wordArray)
                            error = result.error
                            numberOfWordsImported = result.numberOfWordsAdded
                        } else {
                            error = NSError.applicationError(.FailedToImportWords,
                                description: "Failed to import word list named \(name)",
                                failureReason: "Could not parse words list")
                        }
                    } else {
                        error = NSError.applicationError(.FailedToImportWords,
                            description: "Failed to import word list named \(name)",
                            failureReason: "The remote list did could not be converted to a string, ensure it's UTF8 encoded.")
                    }
                }
                completionClosure(error: error, numberOfWordsImported : numberOfWordsImported)
            })
        }
        task.resume()
    }
    
    public func importWords(wordList : [String]) -> (numberOfWordsAdded : Int, error : NSError?) {
        var count = 0
        var error: NSError? = nil
        
        
        // Sort words ascending, trim words
        let words = wordList
            .map{ $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        
            // First get a list of existing words
             let fetchRequest = NSFetchRequest(entityName: "Word")
            fetchRequest.predicate = NSPredicate(format:"(text IN %@) and baby = %@", words, _baby);
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")]
            fetchRequest.propertiesToFetch = ["text"]
            var wordsThatAlreadyExist = NSMutableSet()
            if let words = _managedContext.executeFetchRequest(fetchRequest, error: &error) as [Word]? {
                for word in words {
                    wordsThatAlreadyExist.addObject(word.text.lowercaseString)
                }
            }
        
            for w in words {
                if !w.isEmpty {
                    if wordsThatAlreadyExist.containsObject(w.lowercaseString) {
                        // Skip, already eixts
                        NSLog("Skipped import of %@ because it already exists", w)
                    } else {
                        if let entityDescription = NSEntityDescription.entityForName("Word", inManagedObjectContext:_managedContext) {
                            count++
                            let word = Word(entity: entityDescription, insertIntoManagedObjectContext: _managedContext)
                            word.text = w
                            word.baby = _baby
                            wordsThatAlreadyExist.addObject(w.lowercaseString)
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
    
    public func parseWords(wordString : String) -> [String]? {
        return wordString.componentsSeparatedByString("\n") as [String]
    }
}
