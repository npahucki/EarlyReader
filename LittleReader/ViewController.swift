//
//  ViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/16/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData

// TODO: 
// 1) Each day: Retire oldest word after showing for some amount of time.
// 2) Describe a time to play next word set

class ViewController: UIViewController, UIAlertViewDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var auxMessageLabel: UILabel!

    private var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    private var timer : NSTimer?
    private var currentIdx  = 0
    private var currentWords : [Word]?
    private var currentWordSet : WordSet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont.systemFontOfSize(500)
        NSTimer.scheduledTimerWithTimeInterval(30.0 , target: self, selector: "updateWaitBeforeNextLessonMessage", userInfo: nil, repeats:true)
        resetToDefaultScreen()
    }

    func showNextWord() {
        if let words = currentWords {
            currentIdx++
            setNeedsStatusBarAppearanceUpdate()
            if currentIdx < words.count {
                var animation = CATransition()
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.type = kCATransitionFade;
                animation.duration = 0.25;
                textLabel.layer.addAnimation(animation, forKey: kCATransitionFade)
                
                let word = words[self.currentIdx]
                word.lastViewedOn = NSDate()
                textLabel.text = word.text
                textLabel.setNeedsUpdateConstraints();
                textLabel.setNeedsLayout();
                timer = NSTimer.scheduledTimerWithTimeInterval(UserPreferences.slideDisplayInverval , target: self, selector: "showNextWord", userInfo: nil, repeats: false)
            } else {
                // Stop the timer
                if let t = timer {
                    t.invalidate();
                    timer = nil;
                }
                currentIdx = -1
                didCompleteWordSet(currentWordSet!)
            }
        }
    }
    
    func didCompleteWordSet(wordSet : WordSet) {
        wordSet.lastViewedOn = NSDate()
        saveUpdatedWordsAndSets()
        resetToDefaultScreen()
        scheduleReminder()
        UserPreferences.lastLessonTakenAt = NSDate()
        
        
        updateWaitBeforeNextLessonMessage()
        self.auxMessageLabel.hidden = false;
    }
    
    func willStartWordSet(set : WordSet) {
        auxMessageLabel.hidden = true
        textLabel.text = ""
        textLabel.textColor = UIColor.redColor()
        navigationController?.navigationBar.hidden = true
        // Since we have started a new lesson, we don't want a reminder until after this lesson is complete
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    func findNextWordSet() -> WordSet? {
        var set : WordSet? = nil;
        var error: NSError? = nil
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "WordSet")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
            fetchRequest.fetchLimit = 1
            if let results = ctx.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
                set = results.count > 0 ? results.first : nil
            }
        }
        
        if error != nil {
            UsageAnalytics.trackError("Error trying to load word set from CoreData", error:error!);
        }

        return set;
    }
    
    func scheduleReminder() {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow:  UserPreferences.lessonReminderInverval)
        localNotification.alertBody =  NSLocalizedString("Time for a reading Lesson!", comment:"Main message shown in local notification");
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertAction = NSLocalizedString("Slide to start lesson now", comment:"The side prompt shown in local notification");
        //localNotification.soundName = // : String? // name of resource in app's bundle to play or UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
   
    func updateWaitBeforeNextLessonMessage() {
        if let lastLessonFinished = UserPreferences.lastLessonTakenAt {
            auxMessageLabel.hidden = false
            let nextLessonStart = NSDate(timeInterval: 30.0 * 60.0, sinceDate: lastLessonFinished)
            if(nextLessonStart.timeIntervalSinceNow > 0) {
                auxMessageLabel.text = NSString(format: NSLocalizedString("You should wait at least %d minutes before giving the next lesson",comment: ""),  Int(nextLessonStart.timeIntervalSinceNow / 60.0))
                auxMessageLabel.textColor = UIColor.orangeColor()
                return
            }
        }
        
        auxMessageLabel.text = NSLocalizedString("It's time for the next lesson. Press Start Lesson!",comment: "")
        auxMessageLabel.textColor = UIColor.greenColor()
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return self.currentIdx >= 0
    }
    
    override func viewDidAppear(animated: Bool) {
        updateWaitBeforeNextLessonMessage() // Update the time if needed
    }
    
    @IBAction func didClickStartLesson(sender: UIBarButtonItem) {
        if let wordSet = findNextWordSet() {
            currentWordSet = wordSet
            currentWords = (wordSet.words.allObjects as [Word])
            currentWords!.sort {(_,_) in arc4random() % 2 == 0}
            willStartWordSet(wordSet)
            showNextWord()
        } else {
            // TODO: Automatically load?
            UIAlertView(title: "No Word Sets Loaded", message: "Please go to settings and load some words", delegate: nil, cancelButtonTitle : "Ok").show()
        }
    }
    
    func resetToDefaultScreen() {
        textLabel.text = "LittleReader"
        textLabel.textColor = UIColor .greenColor()
        auxMessageLabel.hidden = false;
        navigationController?.navigationBar.hidden = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func saveUpdatedWordsAndSets() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            var error : NSError? = nil;
            ctx.save(&error)
            if let err = error {
                UsageAnalytics.trackError("Failed to save changed Words and WordSets", error: err)
            }
        }
    }
    

}

