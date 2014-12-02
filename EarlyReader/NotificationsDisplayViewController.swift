//
//  NotificationsViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/20/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

protocol NotificationsDisplayViewControllerDelegate {
    
    // Once the delegate has set the final size of the view, it should call back containerDidFinishExpanding()
    func needsContainerSizeAdjusted(displayController : NotificationsDisplayViewController)
    
}


class NotificationsDisplayViewController: UIViewController, ManagedObjectContextHolder {
    
    
    private let childOffsetDistance = 5
    private let notificationHeight = 100
    private let maxControllers = 10
    private var containerView : UIView!
    private var _needsSizeAdjustment = false
    private var _didInitialLoad = false
    
    
    var managedContext : NSManagedObjectContext?
    var delegate : NotificationsDisplayViewControllerDelegate!
    
    var currentRequiredHeight : Int {
        get {
            return self.childViewControllers.count > 0 ? notificationHeight + ((childViewControllers.count - 1) * childOffsetDistance) : 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataModelChange:", name: NSManagedObjectContextObjectsDidChangeNotification, object:managedContext)
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "checkNeedsSizeAdjustment", userInfo: nil, repeats: true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleDataModelChange(nsNotification : NSNotification) {
        
        var needsRefresh = false;
        
        if _didInitialLoad { // Don't try to process any of this until the initial load completes 
        
            if let insertedObjects = nsNotification.userInfo?[NSInsertedObjectsKey] as? NSSet {
                for obj in insertedObjects {
                    if let notification = obj as? Notification {
                        addNotification(notification)
                        needsRefresh = true
                    }
                }
            }

            if let deletedObjects = nsNotification.userInfo?[NSDeletedObjectsKey] as? NSSet {
                for obj in deletedObjects {
                    if let notification = obj as? Notification {
                        needsRefresh |= removeNotification(notification)
                    }
                }
            }

            if let updatedObjects = nsNotification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
                for obj in updatedObjects {
                    if let notification = obj as? Notification {
                        if contains(notification.changedValuesForCurrentEvent().keys,"closedByUser") && notification.closedByUser {
                            needsRefresh |= removeNotification(notification)
                        }
                    }
                }
            }
        }
        
        if needsRefresh {
            if childViewControllers.count == 0 {
                loadNotifications() // Load next batch
            } else {
                _needsSizeAdjustment = true
            }
        }
    }
    
    // Only adjust the container once every few seconds to keep it from jumping all other the place
    // when there are many updates happening.
    func checkNeedsSizeAdjustment() {
        if _needsSizeAdjustment {
            _needsSizeAdjustment = false
            delegate.needsContainerSizeAdjusted(self)
        }
    }
    
    func loadNotifications() {
        if let notifications = loadSomeNotifications(maxControllers) {
            for n in notifications.reverse() {
                addNotification(n)
            }
            _needsSizeAdjustment = true
            _didInitialLoad = true
        }
    }
    
    func containerDidFinishAdjusting() {
        renderControllers()
    }

    private func loadSomeNotifications(maxCount : Int) ->[Notification]? {
        if let ctx = managedContext {
            var error : NSError? = nil
            let fetchRequest = NSFetchRequest(entityName: "Notification")
            fetchRequest.predicate = NSPredicate(format: "closedByUser = false")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true), NSSortDescriptor(key: "deliveredOn", ascending: false)]
            fetchRequest.fetchLimit = maxCount
            let results = ctx.executeFetchRequest(fetchRequest, error: &error) as [Notification]
            if let err = error {
                UsageAnalytics.instance.trackError("Could not load notifications", error: err)
            } else {
                return results
            }
        }
        
        return nil
        
    }
    
    private func removeNotification(notification : Notification) -> Bool {
        let vcs = self.childViewControllers as [NotificationViewController]
        for vc in vcs {
            if notification == vc.notification {
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
                return true
            }
        }
        return false
    }
    
    private func addNotification(notification : Notification) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("notificationViewController") as NotificationViewController
        vc.notification = notification
        addChildViewController(vc)
        vc.didMoveToParentViewController(self)
        if childViewControllers.count > maxControllers {
            if let vc = childViewControllers.first as? UIViewController {
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
        }
    }
    
    private func renderControllers() {
        containerView?.removeFromSuperview()
        containerView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width, height: self.view.bounds.height))
        self.view.addSubview(containerView)
        let controllers = self.childViewControllers as [NotificationViewController]
        for (indexPosition, vc) in enumerate(controllers) {
            let yOffset = indexPosition * childOffsetDistance
            let xOffset = (controllers.count - indexPosition - 1) * childOffsetDistance
            vc.view.frame = CGRect(x: xOffset, y: yOffset, width: Int(self.view.frame.width) - xOffset * 2, height:notificationHeight)
            vc.view.layer.masksToBounds = false
            vc.view.layer.shadowOffset = CGSizeMake(-1, CGFloat(childOffsetDistance) / -2.0)
            vc.view.layer.shadowRadius = 2
            vc.view.layer.shadowOpacity = 0.3
            containerView.addSubview(vc.view)
        }
    }
    
    func removeLastNotificaitonViewController() {
        let controllers = self.childViewControllers as [NotificationViewController]
        if let vc = controllers.last {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                vc.view.alpha = 0
                for (index, vc) in enumerate(controllers) {
                    if index + 1 < controllers.count {
                        let vcAfter = controllers[index + 1]
                        vc.view.frame = CGRect(x: vcAfter.view.frame.origin.x, y:vc.view.frame.origin.y , width: vcAfter.view.frame.size.width, height: CGFloat(self.notificationHeight))
                    }
                }
            }, completion: { (complete :Bool) -> Void in
                if let ctx = self.managedContext {
                    var error : NSError? = nil
                    vc.notification.closedByUser = true
                    ctx.save(&error)
                    if let err = error {
                        UsageAnalytics.instance.trackError("Could not save context after deleting notification", error: err)
                    }
                }
            })
        }
    }
}