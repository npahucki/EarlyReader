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
    @IBOutlet weak var reminderSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWordCount()
        self.reminderSwitch.on = UserPreferences.lessonRemindersEnabled
    }


    @IBAction func didClickLoadWords(sender: AnyObject) {
        // TODO: Get from S3, make private call.
        let url = NSURL.URLWithString("http://s3.amazonaws.com/InfantIQLittleReader/WordSets/en/basic.txt")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if error != nil {
                let title = NSLocalizedString("Could Not Download Word List", comment: "")
                let msg = NSLocalizedString("Check your network connection and try again please.", comment: "")
                UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Ok").show()
                UsageAnalytics.trackError("Failed to download word list", error: error)
            } else {
                let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
                let words = wordString.componentsSeparatedByString("\n") as [String]
                let count = self.insertWords(words)
                self.updateWordCount()
                
                let title = NSLocalizedString("Sucess!",comment: "")
                let msg = NSLocalizedString("Imported %d new words", comment: "Message for alert box after words have been imported")
                UIAlertView(title: "Success!", message: NSString(format: msg, count), delegate: nil, cancelButtonTitle: "Ok").show()
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
                
            if let err = error {
                let title = NSLocalizedString("Could Not Delete Words", comment: "")
                let cancelButtonTitle = NSLocalizedString("Ok", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
                UsageAnalytics.trackError("Failed to delete words", error: err)
            } else {
                self.updateWordCount()
                let title = NSLocalizedString("Success!", comment: "")
                let msg = NSLocalizedString("Deleted all words.", comment:"")
                let cancelButtonTitle = NSLocalizedString("Ok", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
            }
        }
    }
    
    @IBAction func didChangeReminderSwitch(sender: UISwitch) {
        if(sender.on != UserPreferences.lessonRemindersEnabled) {
            if(sender.on) {
                let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil)
                // Delays the prompt for push notificaitons until now.
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                if !UIApplication.sharedApplication().currentUserNotificationSettings().isEqual(settings) {
                    sender.on = false;
                    let title = NSLocalizedString("Can't Activate Notifiactions", comment:"")
                    let msg = NSLocalizedString("You have previously denied permision to send notifications to LittleReader. You must go to iOS Settings->Notification Center->LittleReader and allow notifications if you want activate reminders.", comment:"")
                    let cancelButtonTitle = NSLocalizedString("Ok",comment:"")
                    UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
                }
            }
            UserPreferences.lessonRemindersEnabled = sender.on;
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
                            }
                        }
                    }
                    ctx.save(&error)
                }
            }

            if let err = error {
                let title = NSLocalizedString("Could not create sets of words.", comment: "")
                let cancelButtonTitle = NSLocalizedString("Ok", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: err.localizedDescription, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
                UsageAnalytics.trackError("Failed to create word sets", error: err)
            } else {
                let title = NSLocalizedString("Success!", comment: "")
                let msg = NSString(format: NSLocalizedString("Created %d sets of words.", comment:""), numberOfWordSets)
                let cancelButtonTitle = NSLocalizedString("Ok", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
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
            if let err = error {
                UsageAnalytics.trackError("Filed to insertWords into CoreData", error: err)
            } else {
                let title = NSString(format: NSLocalizedString("Clear Words (%d)",comment : "Settings menu text"), count)
                self.clearWordsButton.setTitle(title, forState: UIControlState.Normal)
            }
        }

        return count
    }
    
}
