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
    @IBOutlet weak var reminderIntervalStepper: UIStepper!
    @IBOutlet weak var reminderIntervalLabel: UILabel!
    @IBOutlet weak var slideDurationSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWordCount()
        self.reminderIntervalStepper.value = UserPreferences.lessonReminderInverval / 60.0
        didChangeReminderInverval(self.reminderIntervalStepper) // Force label update
        self.slideDurationSlider.value = Float(UserPreferences.slideDisplayInverval)
    }

    @IBAction func didClickLoadWords(sender: AnyObject) {
        // TODO: Get from S3, make private call.
        let url = NSURL.URLWithString("http://s3.amazonaws.com/InfantIQLittleReader/WordSets/en/basic.txt")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if error != nil {
                let title = NSLocalizedString("error_title_download_word_list", comment: "")
                let msg = NSLocalizedString("error_msg_check_network_try_again", comment: "")
                let cancelTitle = NSLocalizedString("uialert_accept_button_title", comment:"")
                UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelTitle).show()
                UsageAnalytics.trackError("Failed to download word list", error: error)
            } else {
                let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
                let words = wordString.componentsSeparatedByString("\n") as [String]
                let count = self.insertWords(words)
                self.updateWordCount()
                
                let title = NSLocalizedString("success_title!",comment: "")
                let msg = NSLocalizedString("success_msg_import_words", comment: "Message for alert box after words have been imported")
                let cancelTitle = NSLocalizedString("uialert_accept_button_title", comment:"")
                UIAlertView(title: "success_title", message: NSString(format: msg, count), delegate: nil, cancelButtonTitle: cancelTitle).show()
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
                let title = NSLocalizedString("error_title_delete_words", comment: "")
                let cancelButtonTitle = NSLocalizedString("uialert_accept_button_title", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
                UsageAnalytics.trackError("Failed to delete words", error: err)
            } else {
                self.updateWordCount()
                let title = NSLocalizedString("success_title", comment: "")
                let msg = NSLocalizedString("success_msg_delete_words", comment:"")
                let cancelButtonTitle = NSLocalizedString("uialert_accept_button_title", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
            }
        }
    }
    
    @IBAction func didChangeReminderInverval(sender: UIStepper) {
        UserPreferences.lessonReminderInverval = NSTimeInterval(sender.value * 60.0)
        let intervalString = NSLocalizedString("settings_label_reminder", comment:"Label in the settings pane for reminder inverval")
        self.reminderIntervalLabel.text = NSString(format: intervalString, Int(sender.value))
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil)
        if !UIApplication.sharedApplication().currentUserNotificationSettings().isEqual(settings) {
            let title = NSLocalizedString("error_title_reminders_cannot_be_sent", comment:"")
            let msg = NSLocalizedString("error_msg_activate_alerts", comment:"")
            let cancelButtonTitle = NSLocalizedString("uialert_accept_button_title",comment:"")
            UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
        }
    }

    
    @IBAction func didChangeSlideDisplayInverval(sender: UISlider) {
        UserPreferences.slideDisplayInverval = NSTimeInterval(sender.value);
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
                let title = NSLocalizedString("error_title_create_word_set", comment: "")
                let cancelButtonTitle = NSLocalizedString("uialert_accept_button_title", comment : "Cancel/Accept button title");
                UIAlertView(title: title, message: err.localizedDescription, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
                UsageAnalytics.trackError("Failed to create word sets", error: err)
            } else {
                let title = NSLocalizedString("success_title", comment: "")
                let msg = NSString(format: NSLocalizedString("success_msg_create_word_sets", comment:""), numberOfWordSets)
                let cancelButtonTitle = NSLocalizedString("uialert_accept_button_title", comment : "Cancel/Accept button title");
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
                let title = NSString(format: NSLocalizedString("settings_menu_clear_words",comment : "Settings menu text"), count)
                self.clearWordsButton.setTitle(title, forState: UIControlState.Normal)
            }
        }

        return count
    }
    
}
