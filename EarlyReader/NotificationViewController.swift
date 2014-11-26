//
//  NotificationViewController.swift
//  
//
//  Created by Nathan  Pahucki on 11/20/14.
//
//

import UIKit

class NotificationViewController: UIViewController {

    var notification : Notification!
    
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
        assert(notification != nil,"Expected notification to be set before view loads!")
        
        typeLabel.text = NSString(format: NSLocalizedString(notification.title, comment : ""))
        if let msg = notification.message {
            detailtextLabel.text = NSString(format: NSLocalizedString(msg, comment : ""))
        }

        switch(NotificationType(rawValue: notification.type.integerValue)!) {
        case NotificationType.Alert:
            imageView.image = UIImage(named: "IconAlerts")
            view.backgroundColor = UIColor.applicationPinkColor()
        case NotificationType.Guidance:
            imageView.image = UIImage(named: "IconAlerts")
            view.backgroundColor = UIColor.applicationBlueColor()
        default:
            imageView.image = UIImage(named: "IconTips")
            view.backgroundColor = UIColor.applicationGreenColor()
        }
    }
}
