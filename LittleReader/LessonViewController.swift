//
//  LessonViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

@objc protocol LessonStateDelegate  {
    func willStartLesson()
    func didCompleteLesson()
}



class LessonViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!


    var lessonPlanner : LessonPlanner!
    
    private var _timer : NSTimer?
    private var _currentIdx  = -1
    private var _currentWords : [Word]?
    private var _isManualMode = UserPreferences.alwaysUseManualMode
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var delegate : LessonStateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(lessonPlanner != nil,"LessonPlanner must be set before starting lesson!")
        textLabel.font = UIFont.systemFontOfSize(500)
        textLabel.text = ""
        updateButtonState()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if _currentIdx == -1 {
            startNextLesson()
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func didPinchScreen(sender: UIPinchGestureRecognizer) {
        if !_isManualMode {
            _isManualMode = true
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
        _currentWords = lessonPlanner.startLesson()
        assert(_currentWords?.count > 0,"LessonViewController should not be show if there are no words!")
        willStartLesson()
        showNextWord()
    }
    
    
    func showNextWord() {
        if let words = _currentWords {
            _currentIdx++
            updateButtonState()
            if _currentIdx < words.count {
                transitionToWord(words[_currentIdx])
                if !_isManualMode {
                    _timer = NSTimer.scheduledTimerWithTimeInterval(UserPreferences.slideDisplayInverval, target: self, selector: "showNextWord", userInfo: nil, repeats: false)
                }
            } else {
                cancelTimer()
                _currentIdx = -1
                didCompleteLesson()
            }
        }
    }

    private func showPreviousWord() {
        if let words = _currentWords {
            _currentIdx--
            updateButtonState()
            if _currentIdx >= 0 {
                transitionToWord(words[_currentIdx])
                if !_isManualMode {
                    _timer = NSTimer.scheduledTimerWithTimeInterval(UserPreferences.slideDisplayInverval, target: self, selector: "showNextWord", userInfo: nil, repeats: false)
                }
            } else {
                didCompleteLesson()
            }
        }
    }
   
    private func cancelTimer() {
        if let t = _timer {
            t.invalidate();
            _timer = nil;
        }
    }
    
    private func updateButtonState() {
        nextButton.hidden = !_isManualMode
        previousButton.hidden = !_isManualMode
        if let words = _currentWords {
            nextButton.setTitle(_currentIdx + 1 < words.count ? ">" : "X", forState: UIControlState.Normal)
            previousButton.setTitle(_currentIdx > 0 ? "<" : "X", forState: UIControlState.Normal)
        }
    }
    
    private func transitionToWord(word: Word) {
        var animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade;
        animation.duration = 0.25;
        textLabel.layer.addAnimation(animation, forKey: kCATransitionFade)
        
        lessonPlanner.markWordViewed(word)
        
        textLabel.text = word.text
        textLabel.setNeedsUpdateConstraints();
        textLabel.setNeedsLayout();
    }
    
    private func didCompleteLesson() {
        lessonPlanner.finishLesson()
        scheduleReminder(lessonPlanner.nextLessonDate)
        if let d = delegate { d.didCompleteLesson() }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func willStartLesson() {
        // Since we have started a new lesson, we don't want a reminder until after this lesson is complete
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        if let d = delegate { d.willStartLesson() }
    }
    
    private func scheduleReminder(forDate: NSDate) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = forDate
        localNotification.alertBody =  NSLocalizedString("local_notification_reminder_alert_body", comment:"Main message shown in local notification");
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertAction = NSLocalizedString("local_notification_reminder_alert_action", comment:"The side prompt shown in local notification");
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }


}
