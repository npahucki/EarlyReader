//
//  LessonViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData



@objc protocol LessonStateDelegate  {
    func willStartLesson()
    func didCompleteLesson()
    func didAbortLesson()
}

class LessonViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var textLabel: UILabel!


    var lessonPlanner : LessonPlanner!
    
    private var _timer : NSTimer?
    private var _currentIdx  = -1
    private var _currentWords : [Word]?
    private var _isManualMode = UserPreferences.alwaysUseManualMode
    private var  _transitionController : SlideInFromRightAnimationController?

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var abortButton: UIButton!
    
    var delegate : LessonStateDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.FullScreen
   }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(lessonPlanner != nil,"LessonPlanner must be set before starting lesson!")
        _currentWords = lessonPlanner.startLesson()
        assert(_currentWords?.count > 0,"LessonViewController should not be show if there are no words!")
        
        textLabel.font = UIFont.systemFontOfSize(500)
        textLabel.text = _currentWords!.first?.text ?? ""
        
        nextButton.alpha = _isManualMode ? 1 : 0
        previousButton.alpha = _isManualMode ? 1 : 0
        abortButton.alpha = _isManualMode ? 1 : 0
        
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
    
    @IBAction func didPressAbortButton(sender: AnyObject) {
        if lessonPlanner.numberOfWordsSeenDuringCurrentLesson >= _currentWords?.count {
            // The lesson is done, no need to prompt 
            didCompleteLesson()
        } else {
            let title = NSLocalizedString("prompt_title_abort_lesson", comment:"")
            let msg = NSLocalizedString("prompt_msg_abort_lesson", comment:"")
            let cancelButtonTitle = NSLocalizedString("prompt_button_no", comment:"")
            let yesButtonTitle = NSLocalizedString("prompt_button_yes", comment:"")
            let prompt = UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: yesButtonTitle)
            prompt.showAlertWithButtonBlock(){
                if $0 == 1 {
                    self.didAbortLesson()
                }
            }
        }
    }
    
    @IBAction func didPressNextButton(sender: AnyObject) {
        pauseAutomaticAdvance()
        showNextWord()
    }
    
    @IBAction func didPressPreviousButton(sender: AnyObject) {
        pauseAutomaticAdvance()
        showPreviousWord()
    }

    @IBAction func didRequestShowButtons(sender: AnyObject) {
        if _isManualMode {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.nextButton.alpha = 0
                self.previousButton.alpha = 0
                self.abortButton.alpha = 0
                }, completion: { (complete : Bool) -> Void in
                    if complete {
                        self.resumeAutomaticAdvance()
                    }
            })
        } else {
            pauseAutomaticAdvance()
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.nextButton.alpha = 1
                self.previousButton.alpha = 1
                self.abortButton.alpha = 1
            })
        }
    }

    
    func startNextLesson() {
        willStartLesson()
        showNextWord()
    }
    
    
    func showNextWord() {
        if let words = _currentWords {
            _currentIdx++
            updateButtonState()
            if _currentIdx < words.count {
                transitionToWord(words[_currentIdx])
                startTimer()
            } else {
                cancelTimer()
                _currentIdx = -1
                didCompleteLesson()
            }
        }
    }

    private func pauseAutomaticAdvance() {
        if !_isManualMode {
            _isManualMode = true
            cancelTimer()
        }
    }

    private func resumeAutomaticAdvance() {
        if _isManualMode {
            _isManualMode = false
            showNextWord()
        }
    }
    
    private func showPreviousWord() {
        if let words = _currentWords {
            _currentIdx--
            updateButtonState()
            if _currentIdx >= 0 {
                transitionToWord(words[_currentIdx])
                startTimer()
            } else {
                didCompleteLesson()
            }
        }
    }
   
    private func startTimer() {
        if !_isManualMode {
            _timer = NSTimer.scheduledTimerWithTimeInterval(UserPreferences.slideDisplayInverval, target: self, selector: "showNextWord", userInfo: nil, repeats: false)
        }
    }
    
    private func cancelTimer() {
        if let t = _timer {
            t.invalidate();
            _timer = nil;
        }
    }
    
    private func updateButtonState() {
        if let words = _currentWords {
            nextButton.hidden = _currentIdx >= words.count
            previousButton.hidden = _currentIdx <= 0
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
    
    private func didAbortLesson() {
        lessonPlanner.finishLesson()
        scheduleReminder(lessonPlanner.nextLessonDate)
        if let d = delegate { d.didAbortLesson() }
        presentingViewController?.dismissViewControllerAnimated(true, completion:nil)
        UsageAnalytics.instance.trackLessonAborted(lessonPlanner)
    }

    private func didCompleteLesson() {
        lessonPlanner.finishLesson()
        scheduleReminder(lessonPlanner.nextLessonDate)
        if let d = delegate { d.didCompleteLesson() }
        presentRewardScreen()
        UsageAnalytics.instance.trackLessonFinished(lessonPlanner)
    }
    
    private func willStartLesson() {
        // Since we have started a new lesson, we don't want a reminder until after this lesson is complete
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        if let d = delegate { d.willStartLesson() }
        UsageAnalytics.instance.trackLessonStarted(lessonPlanner)
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
    
    private func presentRewardScreen() {
        performSegueWithIdentifier("presentRewardScreen", sender: self)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let transitionController = SlideInFromRightAnimationController()
        transitionController.isPresenting = true
        transitionController.duration = 0.75
        return transitionController
        
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let transitionController = SlideInFromRightAnimationController()
        transitionController.isPresenting = false
        transitionController.duration = 0.75
        return transitionController
        
    }


}
