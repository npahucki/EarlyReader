//
//  SettingsViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 9/5/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData


class SettingsListViewController: UITableViewController, ManagedObjectContextHolder {
    
    private var _bubble : PopoverHelper?
    
    var managedContext : NSManagedObjectContext? = nil
    

    
    @IBOutlet weak var babysAgeLabel: UILabel!
    
    @IBOutlet weak var reminderIntervalSlider: UISlider!
    @IBOutlet weak var reminderIntervalLabel: UILabel!
    @IBOutlet weak var numberOfWordSetsSlider: UISlider!
    @IBOutlet weak var numberOfWordSetsLabel: UILabel!
    @IBOutlet weak var slideDurationSlider: UISlider!
    @IBOutlet weak var slideDurationLabel: UILabel!
    @IBOutlet weak var importExportTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderIntervalSlider.value = Float(UserPreferences.lessonReminderInverval / 60.0)
        numberOfWordSetsSlider.value = Float(Baby.currentBaby?.wordSets.count ?? 3.0)
        slideDurationSlider.value = Float(UserPreferences.slideDisplayInverval)
        slideDurationSlider.minimumValue = Float(SLIDE_DURATION_MIN - 0.1)
        slideDurationSlider.maximumValue = Float(SLIDE_DURATION_MAX + 0.1)
        
        // Force label update
        didChangeNumberOfWordSets(numberOfWordSetsSlider)
        didChangeReminderInterval(reminderIntervalSlider)
        didChangeSlideDuration(slideDurationSlider)
        
        #if DEBUG
            importExportTableViewCell.hidden = false
        #else
            importExportTableViewCell.hidden = true
        #endif
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do this here, so that it gets updated after the user changes it in the dialog.
        if let b = Baby.currentBaby {
            var babyInfoString = NSLocalizedString("settings_baby_info", comment:"Label in the settings pane to display the current baby's info")
            babyInfoString = NSString(format: babyInfoString,  b.name,  b.birthDate.stringWithHumanizedTimeDifference(false))
            babysAgeLabel.text = babyInfoString
            
        }
        
        if UIApplication.sharedApplication().respondsToSelector("currentUserNotificationSettings") {
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil)
            if !UIApplication.sharedApplication().currentUserNotificationSettings().isEqual(settings) {
                UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_activate_alerts", title_key: "error_title_reminders_cannot_be_sent")
            }
        }
    }
    
    @IBAction func didChangeNumberOfWordSets(sender: UISlider) {
        sender.value = round(sender.value)
        let newNumberOfWordSets = Int(sender.value)
        if let baby = Baby.currentBaby {
            if baby.wordSets.count != newNumberOfWordSets {
                let result = baby.populateWordSets(newNumberOfWordSets)
                if let err = result.error {
                    UsageAnalytics.instance.trackError("Failed to change the word set count", error: err)
                    UIAlertView.showGenericLocalizedErrorMessage("msg_error_create_word_set")
                    sender.value = Float(baby.wordSets.count)
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(NS_NOTIFICATION_NUMBER_OF_WORD_SETS_CHANGED, object: nil)
                }
            }
        }
        
        let wordSetString = NSLocalizedString("settings_label_number_of_wordsets", comment:"Label in the settings pane for number of WordSets")
        self.numberOfWordSetsLabel.text = NSString(format: wordSetString,  Int(sender.value))
    }
    
    @IBAction func didChangeReminderInterval(sender: UISlider) {
        sender.value = Float(Int(sender.value / 15) * 15) // snap to 15 min intervals
        UserPreferences.lessonReminderInverval = NSTimeInterval(sender.value * 60.0)
        let intervalString = NSLocalizedString("settings_label_reminder", comment:"Label in the settings pane for reminder inverval")
        self.reminderIntervalLabel.text = NSString(format: intervalString, Int(sender.value))
    }

    @IBAction func didTouchSlideDuration(sender : UISlider) {
        if NSUserDefaults.checkFlagNotSetWithKey("settings_help_slide_to_manual") {
            _bubble = PopoverHelper()
            _bubble!.pinToView = sender
            _bubble!.permittedArrowDirections = UIPopoverArrowDirection.Down
            _bubble!.showToolTipBubble(NSLocalizedString("settings_help_slide_to_manual", comment:"")) { () -> () in
                self._bubble = nil
            }
        }
    }
    
    @IBAction func didChangeSlideDuration(sender: UISlider) {
        UserPreferences.slideDisplayInverval = NSTimeInterval(sender.value);
        if sender.value > Float(SLIDE_DURATION_MIN) && sender.value < Float(SLIDE_DURATION_MAX) {
            let intervalString = NSLocalizedString("settings_label_slide_advance", comment:"Label in the settings pane for slide advance inverval seconds")
            self.slideDurationLabel.text = NSString(format: intervalString, sender.value)
        } else {
            self.slideDurationLabel.text = NSLocalizedString("settings_label_slide_advance_manual", comment:"Label in the settings pane for slide advance manual mode")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let movc = segue.destinationViewController as? ManagedObjectContextHolder {
            movc.managedContext = self.managedContext
        }
        if let childInfoVc = segue.destinationViewController as? ChildInfoViewController {
            childInfoVc.baby = Baby.currentBaby
        }
    }
}
