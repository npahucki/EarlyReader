//
//  NotificationsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/20/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

protocol NotificationsDisplayViewControllerDelegate {
    
    func didAddNotification(displayController : NotificationsDisplayViewController, controllerAdded : NotificationViewController)
    func didRemoveNotification(displayController : NotificationsDisplayViewController, controllerRemoved : NotificationViewController)
    
}


class NotificationsDisplayViewController: UIViewController {
    
    private let childOffsetDistance = 10
    private let notificationHeight = 100
    
    private var dirUp = true
    private var _controllers = [NotificationViewController]()
    
    var delegate : NotificationsDisplayViewControllerDelegate?
    
    var currentRequiredHeight : Int {
        get {
            return _controllers.count > 0 ? notificationHeight + (_controllers.count * childOffsetDistance) : 0
        }
    }
    
    override func viewDidLoad() {
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "onTimer", userInfo: nil, repeats: true)
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
            d.didAddNotification(self, controllerAdded: vc)
        }
    }
    
    private func removeLastNotificaitonViewController() {
        if _controllers.count > 0 {
            let vc = _controllers.removeLast()
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            if let d = self.delegate {
                d.didRemoveNotification(self, controllerRemoved: vc)
            }
        }
    }
    
    func onTimer() {
        if _controllers.count > 2 {
            dirUp = false
        } else if(_controllers.count <= 0) {
            dirUp = true
        }
        
        
        if dirUp {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("notificationViewController") as NotificationViewController
            addNotificaitonViewController(vc)
            //vc.detailtextLabel.text = "Controller #\(_controllers.count)"
        } else {
            removeLastNotificaitonViewController()
        }
    }
    
}
