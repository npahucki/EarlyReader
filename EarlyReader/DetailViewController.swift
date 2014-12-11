//
//  DetailViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,NotificationsDisplayViewControllerDelegate, ManagedObjectContextHolder,LessonStateDelegate {

    private var _notificationsViewController : NotificationsDisplayViewController!
    private var _currentDetailViewController : UIViewController?
    
    var managedContext : NSManagedObjectContext? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lessonsCompletedLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rewardBirdImageView: UIImageView!
    @IBOutlet weak var heartsProgressView: HeartsProgressView!
    
    private var _bubble : PopoverHelper?
    

    var currentDetailViewController : UIViewController? {
        get {
            return _currentDetailViewController
        }
        set(newVc) {
            // Out with the old...
            if let oldVc = _currentDetailViewController {
                oldVc.removeFromParentViewController()
                oldVc.view.removeFromSuperview()
            }

            // In with the new...
            _currentDetailViewController = newVc
            if let vc = newVc {
                titleLabel.text = vc.title
                let childView = vc.view
                childView.frame = CGRect(x: 0.0, y: 0.0, width: containerView.bounds.width, height: containerView.bounds.height)
                containerView.addSubview(childView)
                addChildViewController(vc)
                vc.didMoveToParentViewController(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerHeightConstraint.constant = 0
        view.layoutIfNeeded()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: _notificationsViewController, selector: "loadNotifications", userInfo: nil, repeats: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLessonProgress", name: NS_NOTIFICATION_NUMBER_OF_WORD_SETS_CHANGED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLessonProgress", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        let tapRecognizer1 = UITapGestureRecognizer()
        tapRecognizer1.addTarget(self, action: "showHeartsHelpText")
        heartsProgressView.addGestureRecognizer(tapRecognizer1)
        
        let tapRecognizer2 = UITapGestureRecognizer()
        tapRecognizer2.addTarget(self, action: "showBirdHelpText")
        rewardBirdImageView.userInteractionEnabled = true
        rewardBirdImageView.addGestureRecognizer(tapRecognizer2)

        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateLessonProgress()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let notificationsController = segue.destinationViewController as? NotificationsDisplayViewController {
            _notificationsViewController = notificationsController
            notificationsController.managedContext = managedContext
            notificationsController.delegate = self
        }
    }

    func willStartLesson() {
        // NOOP
    }
    
    func didCompleteLesson() {
        updateLessonProgress()
    }
    
    func didAbortLesson() {
        updateLessonProgress()
    }

    
    
    // Once the delegate has set the final size of the view, it should call back containerDidFinishExpanding()
    func needsContainerSizeAdjusted(displayController: NotificationsDisplayViewController) {
        view.layoutIfNeeded()
        containerHeightConstraint.constant = CGFloat(displayController.currentRequiredHeight)
        UIView.animateWithDuration(0.3, delay: 0.0, options:  .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (complete : Bool) -> Void in
                displayController.containerDidFinishAdjusting()
        }
    }
    
    func updateLessonProgress() {
        //                NSForegroundColorAttributeName : UIColor.applicationTextColor(),
        if let baby = Baby.currentBaby {
            let lessonPlanner = LessonPlanner(baby: baby)
            let completedText = NSString(format: NSLocalizedString("msg_lessons_completed_today", comment:"Text shown in main detail view for how many lessons for today have been completed"),lessonPlanner.numberOfLessonsTakenToday,lessonPlanner.numberOfLessonsPerDay)
            let attrString  = NSMutableAttributedString(string: completedText, attributes: [
                NSForegroundColorAttributeName : UIColor.applicationTextColor(),
                NSFontAttributeName : UIFont(name: "OpenSans-Light", size: 17.0)!
                ])
            // Now fish out the numbers and make them bold - PITA!!!
            let numberOfLessonsTakenTodayRange = completedText.rangeOfString(String(lessonPlanner.numberOfLessonsTakenToday))
            let numberOfLessonsPerDayRange = completedText.rangeOfString(String(lessonPlanner.numberOfLessonsPerDay), options: NSStringCompareOptions.BackwardsSearch)
            let boldFont = UIFont(name: "OpenSans-Semibold", size: 17.0)!
            attrString.setAttributes([NSFontAttributeName : boldFont], range: numberOfLessonsPerDayRange)
            attrString.setAttributes([NSFontAttributeName : boldFont], range: numberOfLessonsTakenTodayRange)
            lessonsCompletedLabel.attributedText = attrString
            heartsProgressView.setLesson(lessonPlanner.numberOfLessonsTakenToday, totalLessons: lessonPlanner.numberOfLessonsPerDay,wordSets:baby.wordSets.count)
            if lessonPlanner.numberOfLessonsRemainingToday == 0 {
                rewardBirdImageView.image = UIImage(named:   "RewardBirdCrown")
            } else {
                rewardBirdImageView.image = UIImage(named:   "RewardBird")
            }
        }
    }
    
    func showHeartsHelpText() {
        _bubble = PopoverHelper()
        _bubble!.pinToView = heartsProgressView
        _bubble!.permittedArrowDirections = UIPopoverArrowDirection.Up
        _bubble!.showToolTipBubble(NSLocalizedString("hearts_help_text", comment: "")) { () -> () in
            self._bubble = nil
        }
    }

    func showBirdHelpText() {
        _bubble = PopoverHelper()
        _bubble!.pinToView = rewardBirdImageView
        _bubble!.permittedArrowDirections = UIPopoverArrowDirection.Up
        _bubble!.showToolTipBubble(NSLocalizedString("bird_help_text", comment: "")) { () -> () in
            self._bubble = nil
        }
    }

    
    
}