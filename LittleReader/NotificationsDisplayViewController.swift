//
//  NotificationsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/20/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

protocol NotificationsDisplayViewControllerDelegate {
    
    func didAddNotifications(displayController : NotificationsDisplayViewController)
    func didRemoveNotifications(displayController : NotificationsDisplayViewController)
    
}


class NotificationsDisplayViewController: UIViewController, ManagedObjectContextHolder {
    
    
    private let childOffsetDistance = 10
    private let notificationHeight = 100
    
    private var dirUp = true
    private var _controllers = [NotificationViewController]()
    private var fetchedResultsController = NSFetchedResultsController()
    
    var managedContext : NSManagedObjectContext? = nil
    var delegate : NotificationsDisplayViewControllerDelegate?
    
    var currentRequiredHeight : Int {
        get {
            return _controllers.count > 0 ? notificationHeight + (_controllers.count * childOffsetDistance) : 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotifications()
    }
    
    func loadNotifications() {
        
        // TEMP:
        let entityDescription = NSEntityDescription.entityForName("Notification", inManagedObjectContext:managedContext!)
        let n1 = Notification(entity: entityDescription!, insertIntoManagedObjectContext: managedContext!)
        n1.deliveredOn = NSDate()
        n1.message = "This is a tip"
        n1.type = NotificationType.Tip.rawValue
        managedContext!.insertObject(n1)
        
        let n2 = Notification(entity: entityDescription!, insertIntoManagedObjectContext: managedContext!)
        n2.deliveredOn = NSDate().dateYesterday()
        n2.message = "This is an alert"
        n2.type = NotificationType.Alert.rawValue
        managedContext!.insertObject(n2)
        
        managedContext!.save(nil)
        // END TEMP
        
        
        if let ctx = managedContext {
            var error : NSError? = nil
            let fetchRequest = NSFetchRequest(entityName: "Notifications")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "deliveredOn", ascending: false)]
            let results = ctx.executeFetchRequest(fetchRequest, error: &error) as [Notification]
            if let err = error {
                UsageAnalytics.trackError("Could not load notifications", error: err)
            } else {
                _controllers.removeAll(keepCapacity: true)
                for n in results {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("notificationViewController") as NotificationViewController
                    vc.notification = n
                    addNotificaitonViewController(vc)
                    _controllers.append(vc)
                }
                if let d = delegate {
                    d.didAddNotifications(self)
                }
            }
        }
    }
    
    private func addNotificaitonViewController(vc: NotificationViewController) {
        let offset = _controllers.count * childOffsetDistance
        // NOTE: I don't know why, but if you set the height to something for the very first controller, it gets ADDED to the
        // the notificationHeight, so I set it to zero and then the frame ends up with a proper height. .shrug!
        vc.view.frame = CGRect(x: 0, y: offset, width: Int(self.view.frame.width), height: offset == 0 ? 0 : notificationHeight)
        vc.view.layer.masksToBounds = false
        vc.view.layer.shadowOffset = CGSizeMake(-1, -3)
        vc.view.layer.shadowRadius = 2
        vc.view.layer.shadowOpacity = 0.3
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
        _controllers.append(vc)
        if let d = self.delegate {
            d.didAddNotifications(self)
        }
    }
    
    func removeLastNotificaitonViewController() {
        if _controllers.count > 0 {
            let vc = _controllers.removeLast()
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            if let d = self.delegate {
                d.didRemoveNotifications(self)
            }
            
            if let ctx = managedContext {
                var error : NSError? = nil
                ctx.deleteObject(vc.notification!)
                ctx.save(&error)
                if let err = error {
                    UsageAnalytics.trackError("Could not save context after deleting notification", error: err)
                }
            }
        }
    }
}