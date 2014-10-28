//
//  LessonViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

protocol LessonStateDelegate  {
    func willStartLesson()
    func didCompleteLesson()
}



class LessonViewController: UIViewController,NSFetchedResultsControllerDelegate, ManagedObjectContextHolder {

    var managedContext : NSManagedObjectContext? = nil

    
    @IBOutlet weak var textLabel: UILabel!
    
    private var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    private var timer : NSTimer?
    private var currentIdx  = -1
    private var currentWords : [Word]?
    private var currentWordSet : WordSet?
    private var isManualMode = false
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var delegate : LessonStateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont.systemFontOfSize(500)
        textLabel.text = ""
        updateButtonState()
        self.isManualMode = UserPreferences.alwaysUseManualMode
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentIdx == -1 {
            startNextLesson()
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func didPinchScreen(sender: UIPinchGestureRecognizer) {
        if !isManualMode {
            isManualMode = true
            cancelTimer()
            updateButtonState()
        }
    }
    
    @IBAction func didPressNextButton(sender: AnyObject) {
        showNextWord()
    }
    
    @IBAction func didPressPreviousButton(sender: AnyObject) {
        showPreviousWord()
    }
    
        
    func startNextLesson() {
        if let wordSet = findNextWordSet() {
            currentWordSet = wordSet
            currentWords = (wordSet.words.allObjects as [Word])
            currentWords!.sort {(_,_) in arc4random() % 2 == 0}
            willStartWordSet(wordSet)
            updateButtonState()
            showNextWord()
        } else {
            // TODO: Automatically load?
            UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_no_wordsets", title_key: "error_title_no_wordsets")
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    
    func showNextWord() {
        if let words = currentWords {
            currentIdx++
            updateButtonState()
            if currentIdx < words.count {
                transitionToWord(words[currentIdx])
                if !isManualMode {
                    timer = NSTimer.scheduledTimerWithTimeInterval(UserPreferences.slideDisplayInverval, target: self, selector: "showNextWord", userInfo: nil, repeats: false)
                }
            } else {
                cancelTimer()
                currentIdx = -1
                didCompleteWordSet(currentWordSet!)
            }
        }
    }

    private func showPreviousWord() {
        if let words = currentWords {
            currentIdx--
            updateButtonState()
            if currentIdx >= 0 {
                transitionToWord(words[currentIdx])
                if !isManualMode {
                    timer = NSTimer.scheduledTimerWithTimeInterval(UserPreferences.slideDisplayInverval, target: self, selector: "showNextWord", userInfo: nil, repeats: false)
                }
            } else {
                didCompleteWordSet(currentWordSet!)
            }
        }
    }
   
    private func cancelTimer() {
        if let t = timer {
            t.invalidate();
            timer = nil;
        }
    }
    
    private func updateButtonState() {
        nextButton.hidden = !isManualMode
        previousButton.hidden = !isManualMode
        if let words = currentWords {
            nextButton.setTitle(currentIdx + 1 < words.count ? ">" : "X", forState: UIControlState.Normal)
            previousButton.setTitle(currentIdx > 0 ? "<" : "X", forState: UIControlState.Normal)
        }
    }
    
    private func transitionToWord(word: Word) {
        var animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade;
        animation.duration = 0.25;
        textLabel.layer.addAnimation(animation, forKey: kCATransitionFade)
        
        word.lastViewedOn = NSDate()
        word.timesViewed++
        
        textLabel.text = word.text
        textLabel.setNeedsUpdateConstraints();
        textLabel.setNeedsLayout();
    }
    
    private func didCompleteWordSet(wordSet : WordSet) {
        wordSet.lastViewedOn = NSDate()
        var retireResult = wordSet.retireOldWord()
        var fillResult = wordSet.fill()
        NSLog("From WordSet #%@, %d words were retired and %d new words were added back in.", wordSet.number, retireResult.wasWordRetired ? 1 : 0, fillResult.numberOfWordsAdded);
        saveUpdatedWordsAndSets()
        UserPreferences.lastLessonTakenAt = NSDate()
        scheduleReminder()
        if let d = delegate { d.didCompleteLesson() }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        if let e = retireResult.error {
            UsageAnalytics.trackError("Could not retire words in word set", error: e)
        }
        if let e = fillResult.error {
            UsageAnalytics.trackError("Could not fill words in word set", error: e)
        }
    }
    
    private func willStartWordSet(set : WordSet) {
        // Since we have started a new lesson, we don't want a reminder until after this lesson is complete
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        if let d = delegate { d.willStartLesson() }
    }
    
    private func findNextWordSet() -> WordSet? {
        var set : WordSet? = nil;

        
        if let baby = Baby.currentBaby {
            var error: NSError? = nil
            if let ctx = managedContext {
                let fetchRequest = NSFetchRequest(entityName: "WordSet")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = NSPredicate(format: "(baby == %@)",baby)
                if let results = ctx.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
                    set = results.count > 0 ? results.first : nil
                }
            }
            
            if error != nil {
                UsageAnalytics.trackError("Error trying to load word set from CoreData", error:error!);
            }
        } else {
            NSLog("No Baby set!");
        }
        
        return set;
    }
    
    private func saveUpdatedWordsAndSets() {
        if let ctx = managedContext {
            var error : NSError? = nil;
            ctx.save(&error)
            if let err = error {
                UsageAnalytics.trackError("Failed to save changed Words and WordSets", error: err)
            }
        }
    }
    
    private func scheduleReminder() {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow:  UserPreferences.lessonReminderInverval)
        localNotification.alertBody =  NSLocalizedString("local_notification_reminder_alert_body", comment:"Main message shown in local notification");
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertAction = NSLocalizedString("local_notification_reminder_alert_action", comment:"The side prompt shown in local notification");
        //localNotification.soundName = // : String? // name of resource in app's bundle to play or UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }


}
