//
//  IdleScreenViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class LessonsViewController: UIViewController, LessonStateDelegate, NotificationsDisplayViewControllerDelegate, ManagedObjectContextHolder {

    
    
    private var _notificationsViewController : NotificationsDisplayViewController!
    private var _lessonHistoryController : LessonsListViewController!
    private var _planner : LessonPlanner?
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    var managedContext : NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        containerHeightConstraint.constant = 0
        view.setNeedsLayout()
        _notificationsViewController.loadNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let b = Baby.currentBaby {
            _planner = LessonPlanner(baby: b)
            if let vc = _lessonHistoryController {
               vc.baby = Baby.currentBaby
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let historyController = segue.destinationViewController as? LessonsListViewController {
            historyController.baby = Baby.currentBaby
            _lessonHistoryController = historyController
        } else if let notificationsController = segue.destinationViewController as? NotificationsDisplayViewController {
            _notificationsViewController = notificationsController
            notificationsController.managedContext = managedContext
            notificationsController.delegate = self
        }
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
    
    
    // MARK: LessonStateDeletegate methods
    func willStartLesson() {
    }
    
    func didCompleteLesson() {
    }
    
    func didAbortLesson() {
    }

}
