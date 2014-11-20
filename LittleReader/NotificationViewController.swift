//
//  NotificationViewController.swift
//  
//
//  Created by Nathan  Pahucki on 11/20/14.
//
//

import UIKit

class NotificationViewController: UIViewController {

    private var _notification : Notification?
    
    var notification : Notification? {
        get {
            return _notification
        }
        set {
            _notification = notification
            updateStateForNotification()
        }
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var detailtextLabel: UILabel!
    
    
    @IBAction func didClickCloseNotification(sender: AnyObject) {
        if let parentVc = parentViewController as? NotificationsDisplayViewController {
            parentVc.removeLastNotificaitonViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func updateStateForNotification() {
        // TODO: Update the UI!
    }
    
    
}
