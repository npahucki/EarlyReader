//
//  DetailViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,NotificationsDisplayViewControllerDelegate, ManagedObjectContextHolder {

    private var _notificationsViewController : NotificationsDisplayViewController!

    var managedContext : NSManagedObjectContext? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var currentDetailViewController : UIViewController? {
        get {
            return childViewControllers.last as? UIViewController
        }
        set(newVc) {
            // Out with the old...
            if let oldVc = childViewControllers.last as? UIViewController {
                if oldVc != _notificationsViewController {
                    oldVc.removeFromParentViewController()
                    oldVc.view.removeFromSuperview()
                }
            }

            // In with the new...
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
        //_notificationsViewController.loadNotifications()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: _notificationsViewController, selector: "loadNotifications", userInfo: nil, repeats: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let notificationsController = segue.destinationViewController as? NotificationsDisplayViewController {
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

    
}
