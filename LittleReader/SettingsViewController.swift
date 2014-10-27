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
                UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_check_network_try_again", title_key: "error_title_download_word_list")
                UsageAnalytics.trackError("Failed to download word list", error: error)
            } else {
                // Called on background thread
                dispatch_async(dispatch_get_main_queue(),{ () -> Void in
                    let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
                    let words = wordString?.componentsSeparatedByString("\n") as [String]
                    self.insertWords(words)
                    self.updateWordCount()
                    UIAlertView.showGenericLocalizedSuccessMessage("msg_success_import_words")
                    loadingWordsIndicator.stopAnimating()
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
                UIAlertView.showGenericLocalizedErrorMessage("msg_error_delete_words")
                UsageAnalytics.trackError("Could not delete words", error: err)
            } else {
                self.updateWordCount()
                UIAlertView.showGenericLocalizedSuccessMessage("msg_success_delete_words")
            }
        }
    }
    
    @IBAction func didChangeReminderInverval(sender: UIStepper) {
        UserPreferences.lessonReminderInverval = NSTimeInterval(sender.value * 60.0)
        let intervalString = NSLocalizedString("settings_label_reminder", comment:"Label in the settings pane for reminder inverval")
        self.reminderIntervalLabel.text = NSString(format: intervalString, Int(sender.value))
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil)
        if !UIApplication.sharedApplication().currentUserNotificationSettings().isEqual(settings) {
            UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_activate_alerts", title_key: "error_title_reminders_cannot_be_sent")
        }
    }
    
    
    @IBAction func didChangeSlideDisplayInverval(sender: UISlider) {
        UserPreferences.slideDisplayInverval = NSTimeInterval(sender.value);
    }
    
    @IBAction func didClickRecreateWordLists(sender: AnyObject) {
        let numberOfWordSets = 5 // TODO: Read from settings
        
        if let baby = Baby.currentBaby {
            var result = baby.populateWordSets(numberOfWordSets, numberOfWordsPerSet: 5)
            if let e = result.error {
                UsageAnalytics.trackError("Failed to save new word sets", error: e)
                UIAlertView.showGenericLocalizedErrorMessage("msg_error_create_word_set")
            }  else if result.numberOfWordSetsCreated > 0 {
                UIAlertView.showGenericLocalizedSuccessMessage("msg_success_create_word_sets")
            } else {
                UIAlertView.showGenericLocalizedErrorMessage("msg_create_word_set_none")
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
    
    func insertWords(words : [String]) {
        if let ctx = managedContext {
            let importer = WordImporter(managedContext:ctx)
            let result = importer.importWords(words)
            if let err = result.error {
                UsageAnalytics.trackError("Failed to insertWords into CoreData", error: err)
            } else {
                let title = NSString(format: NSLocalizedString("settings_menu_clear_words",comment : "Settings menu text"), result.numberOfWordsAdded)
                self.clearWordsButton.setTitle(title, forState: UIControlState.Normal)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }
    
    
}
