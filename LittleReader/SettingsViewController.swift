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
    @IBOutlet weak var numberOfWordSetsStepper: UIStepper!
    @IBOutlet weak var numberOfWordSetsLabel: UILabel!
    @IBOutlet weak var manualAdvanceOnlySwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWordCount()
        self.reminderIntervalStepper.value = UserPreferences.lessonReminderInverval / 60.0
        self.numberOfWordSetsStepper.value = Double(Baby.currentBaby?.wordSets.count ?? 3)
        didChangeReminderInverval(self.reminderIntervalStepper) // Force label update
        didChangeNumberOfWordSets(self.numberOfWordSetsStepper)
        self.slideDurationSlider.value = Float(UserPreferences.slideDisplayInverval)
        self.manualAdvanceOnlySwitch.on = UserPreferences.alwaysUseManualMode
        self.slideDurationSlider.enabled = !UserPreferences.alwaysUseManualMode

    }
    
    @IBAction func didChangeManualAdvanceOnly(sender: UISwitch) {
        UserPreferences.alwaysUseManualMode = sender.on
        self.slideDurationSlider.enabled = !sender.on
    }
    
    @IBAction func didClickLoadWords(sender: AnyObject) {
        // TODO: Get from S3, make private call, or use a signed URL that expires waaaaay in the future.
        loadingWordsIndicator.startAnimating()
        let url = NSURL(string: "http://s3.amazonaws.com/InfantIQLittleReader/WordSets/en/basic.txt")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                // Called on background thread
            dispatch_async(dispatch_get_main_queue(),{ () -> Void in
                if error != nil {
                    self.loadingWordsIndicator.stopAnimating()
                    UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_check_network_try_again", title_key: "error_title_download_word_list")
                    UsageAnalytics.trackError("Failed to download word list", error: error)
                } else {
                    let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
                    let words = wordString?.componentsSeparatedByString("\n") as [String]
                    self.insertWords(words)
                    UIAlertView.showGenericLocalizedSuccessMessage("msg_success_import_words")
                    self.loadingWordsIndicator.stopAnimating()
                }
            })
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
        if UIApplication.sharedApplication().respondsToSelector("currentUserNotificationSettings") {
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil)
            if !UIApplication.sharedApplication().currentUserNotificationSettings().isEqual(settings) {
            UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_activate_alerts", title_key: "error_title_reminders_cannot_be_sent")
            }
        }
    }
    
    
    
    @IBAction func didChangeNumberOfWordSets(sender: UIStepper) {
        let newNumberOfWordSets = Int(sender.value)

        if let baby = Baby.currentBaby {
            if baby.wordSets.count != newNumberOfWordSets {
                let result = baby.populateWordSets(newNumberOfWordSets)
                if let err = result.error {
                    UsageAnalytics.trackError("Failed to change the word set count", error: err)
                    UIAlertView.showGenericLocalizedErrorMessage("msg_error_create_word_set")
                }
                sender.value = Double(baby.wordSets.count)
            }
        }
        
        let wordSetString = NSLocalizedString("settings_label_number_of_wordsets", comment:"Label in the settings pane for number of WordSets")
        self.numberOfWordSetsLabel.text = NSString(format: wordSetString,  Int(sender.value))

    }
    
    @IBAction func didChangeSlideDisplayInverval(sender: UISlider) {
        UserPreferences.slideDisplayInverval = NSTimeInterval(sender.value);
    }
    
    func updateWordCount() {
        if let ctx = managedContext {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            let count = ctx.countForFetchRequest(fetchRequest, error: nil)
            let title = NSString(format: NSLocalizedString("settings_menu_clear_words",comment : "Settings menu text"), count)
            self.clearWordsButton.setTitle(title, forState: UIControlState.Normal)
        }
    }
    
    func insertWords(words : [String]) {
        if let ctx = managedContext {
            let importer = WordImporter(managedContext:ctx)
            let result = importer.importWords(words)
            if let err = result.error {
                UsageAnalytics.trackError("Failed to insertWords into CoreData", error: err)
            } else {
                if let baby = Baby.currentBaby {
                    let numSets = baby.wordSets.count > 0 ? baby.wordSets.count : 1
                    baby.populateWordSets(numSets)
                    updateWordCount()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
        
        if let vc = segue.destinationViewController as? AddWordsViewController {
            vc.settingsViewController = self
        }
        
    }
    
    
}
