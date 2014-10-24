//
//  SettingsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 9/5/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData


class SettingsViewController: UITableViewController, ManagedObjectContextHolder {

    var managedContext : NSManagedObjectContext? = nil

    
    @IBOutlet weak var clearWordsButton: UIButton!
    @IBOutlet weak var reminderIntervalStepper: UIStepper!
    @IBOutlet weak var reminderIntervalLabel: UILabel!
    @IBOutlet weak var slideDurationSlider: UISlider!
    @IBOutlet weak var loadingWordsIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWordCount()
        self.reminderIntervalStepper.value = UserPreferences.lessonReminderInverval / 60.0
        didChangeReminderInverval(self.reminderIntervalStepper) // Force label update
        self.slideDurationSlider.value = Float(UserPreferences.slideDisplayInverval)
    }

    @IBAction func didClickLoadWords(sender: AnyObject) {
        // TODO: Get from S3, make private call.
        loadingWordsIndicator.startAnimating()
        let url = NSURL(string: "http://s3.amazonaws.com/InfantIQLittleReader/WordSets/en/basic.txt")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if error != nil {
                UIAlertView.showLocalizedErrorMessageWithOkButton("error_msg_check_network_try_again", title_key: "error_title_download_word_list")
                UsageAnalytics.trackError("Failed to download word list", error: error)
            } else {
                // Called on background thread
                dispatch_async(dispatch_get_main_queue(),{ () -> Void in
                    let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
                    let words = wordString?.componentsSeparatedByString("\n") as [String]
                    let count = self.insertWords(words)
                    self.updateWordCount()
                    UIAlertView.showGenericLocalizedSuccessMessage("success_msg_import_words")
                })
            }
        }
        
        task.resume()
    }
    
    @IBAction func didClickClearWords(sender: AnyObject) {
        if let ctx = managedContext {
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
                UIAlertView.showGenericLocalizedErrorMessage("error_msg_delete_words")
                UsageAnalytics.trackError("Could not delete words", error: err)
            } else {
                self.updateWordCount()
                UIAlertView.showGenericLocalizedSuccessMessage("success_msg_delete_words")
            }
        }
    }
    
    @IBAction func didChangeReminderInverval(sender: UIStepper) {
        UserPreferences.lessonReminderInverval = NSTimeInterval(sender.value * 60.0)
        let intervalString = NSLocalizedString("settings_label_reminder", comment:"Label in the settings pane for reminder inverval")
        self.reminderIntervalLabel.text = NSString(format: intervalString, Int(sender.value))
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil)
        if !UIApplication.sharedApplication().currentUserNotificationSettings().isEqual(settings) {
            UIAlertView.showLocalizedErrorMessageWithOkButton("error_msg_activate_alerts", title_key: "error_title_reminders_cannot_be_sent")
        }
    }

    
    @IBAction func didChangeSlideDisplayInverval(sender: UISlider) {
        UserPreferences.slideDisplayInverval = NSTimeInterval(sender.value);
    }
    
    @IBAction func didClickRecreateWordLists(sender: AnyObject) {
        let numberOfWordSets = 5
        
        if let ctx = managedContext {
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
                            wordSet.baby = Baby.currentBaby!
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
                UIAlertView.showGenericLocalizedErrorMessage("error_msg_create_word_set")
                UsageAnalytics.trackError("Failed to create word sets", error: err)
            } else {
                UIAlertView.showGenericLocalizedSuccessMessage("success_msg_create_word_sets")
            }
        }
    }
    
    func updateWordCount() {
        if let ctx = managedContext {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            let count = ctx.countForFetchRequest(fetchRequest, error: nil)
            self.clearWordsButton.setTitle("Clear Words (\(count))", forState: UIControlState.Normal)
        }
    }
    
    func insertWords(words : [String]) -> Int {
        var count = -1
        if let ctx = managedContext {
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
            loadingWordsIndicator.stopAnimating()
            if let err = error {
                UsageAnalytics.trackError("Filed to insertWords into CoreData", error: err)
            } else {
                let title = NSString(format: NSLocalizedString("settings_menu_clear_words",comment : "Settings menu text"), count)
                self.clearWordsButton.setTitle(title, forState: UIControlState.Normal)
            }
        }

        return count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }

    
}
