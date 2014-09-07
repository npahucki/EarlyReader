//
//  SettingsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 9/5/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData


class SettingsViewController: UITableViewController {

    @IBOutlet weak var clearWordsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWordCount()
    }


    @IBAction func didClickLoadWords(sender: AnyObject) {
        // TODO: Get from S3, make private call.
        let url = NSURL.URLWithString("http://s3.amazonaws.com/InfantIQLittleReader/WordSets/en/basic.txt")
        NSLog("Loading words from source...")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if error != nil {
                UIAlertView(title: "Error!", message: "Could not download word list", delegate: nil, cancelButtonTitle: "Ok").show()
                NSLog("Failed to download word list: %@", error!)
            } else {
                NSLog("Parsing words...")
                let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
                let words = wordString.componentsSeparatedByString("\n") as [String]
                NSLog("Saving words in DB...")
                let count = self.insertWords(words)
                self.updateWordCount()
                NSLog("YAY, \(count) words loaded and saved")
                UIAlertView(title: "Success!", message: "Imported \(count) new words", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }
        
        task.resume()
    }
    
    @IBAction func didClickClearWords(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
            fetchRequest.includesPropertyValues = false

            var error : NSError? = nil;
            let words = ctx.executeFetchRequest(fetchRequest, error: &error)
            if error == nil {
                for word in words as [Word] {ctx.deleteObject(word)}
                ctx.save(&error)
            }
                
            if error == nil {
                self.updateWordCount()
                UIAlertView(title: "Success!", message: "Deleted all words", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                UIAlertView(title: "Error!", message: "Could not delete words", delegate: nil, cancelButtonTitle: "Ok").show()
                NSLog("Failed to delete words : %@", error!)
            }
        }
    }
    
    
    @IBAction func didClickRecreateWordLists(sender: AnyObject) {
        let numberOfWordSets = 5
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            var error : NSError? = nil;
            let fetchRequest = NSFetchRequest(entityName: "WordSet")
            fetchRequest.includesPropertyValues = false
            let wordSets = ctx.executeFetchRequest(fetchRequest, error: &error)
            if error == nil {
                for wordSet in wordSets as [WordSet] {
                    ctx.deleteObject(wordSet)
                    NSLog("Deleting WordSet #%@", wordSet.number)
                }
                ctx.save(&error)
            }
            
            if(error == nil) {
                // Create 5 sets of 5 words
                let fetchRequest = NSFetchRequest(entityName: "Word")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
                fetchRequest.fetchLimit = 25;
                fetchRequest.predicate = NSPredicate(format: "wordSet = NULL", argumentArray: nil)
                if let words = ctx.executeFetchRequest(fetchRequest, error: &error) as? [Word] {
                    let wordsPerGroup = words.count / numberOfWordSets
                    let oddWords = words.count % numberOfWordSets // TODO: something with this
                    var wordIdx = 0
                    for var i = 0; i < numberOfWordSets; i++ {
                        if let entityDescripition = NSEntityDescription.entityForName("WordSet", inManagedObjectContext:ctx) {
                            let wordSet = WordSet(entity: entityDescripition, insertIntoManagedObjectContext: ctx)
                            wordSet.number = i
                            wordSet.words = NSMutableSet()
                            for var ii = 0; ii < wordsPerGroup; ii++ {
                                let word = words[wordIdx++]
                                wordSet.words.addObject(word)
                                word.wordSet = wordSet // TODO: See if this is neccesssary
                                word.activatedOn = NSDate()
                                NSLog("Added word '%@' to wordSet #%@",word.text,wordSet.number)
                                NSLog("Word's set #%@",word.wordSet.number)
                            }
                        }
                    }
                    ctx.save(&error)
                }
            }

            if error == nil {
                UIAlertView(title: "Success!", message: "Created \(numberOfWordSets) sets of words", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                UIAlertView(title: "Error!", message: "Could not create sets of words", delegate: nil, cancelButtonTitle: "Ok").show()
                NSLog("Failed to delete words : %@", error!)
            }
        }
    }
    
    func updateWordCount() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            let count = ctx.countForFetchRequest(fetchRequest, error: nil)
            self.clearWordsButton.setTitle("Clear Words (\(count))", forState: UIControlState.Normal)
        }
    }
    
    func insertWords(words : [String]) -> Int {
        var count = -1
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            if let entityDescripition = NSEntityDescription.entityForName("Word", inManagedObjectContext:ctx) {
                count = 0
                for w in words {
                    if !w.isEmpty {
                        count++
                        let word = Word(entity: entityDescripition, insertIntoManagedObjectContext: ctx)
                        word.text = w
                    }
                }
            }
            
            var error: NSError? = nil
            ctx.save(&error)
            if error == nil {
                NSLog("Words Saved")
                self.clearWordsButton.setTitle("Clear Words (\(count))", forState: UIControlState.Normal)
            } else {
                NSLog("FAILED: %@",error!);
            }
        }

        return count
    }
    
}
