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
        
        switch(notification.type.integerValue) {
        case NotificationType.Alert.rawValue:
            imageView.image = UIImage(named: "IconAlerts")
            view.backgroundColor = UIColor.applicationOrangeColor()
            typeLabel.text = NSLocalizedString("notification_type_alert", comment:"")
        default:
            imageView.image = UIImage(named: "IconTips")
            view.backgroundColor = UIColor.applicationGreenColor()
            typeLabel.text = NSLocalizedString("notification_type_tip", comment:"")
        }
        detailtextLabel.text = notification.message
    }
}
