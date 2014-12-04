//
//  MenuViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
@objc
class MenuViewController: UIViewController, UIPopoverControllerDelegate {

    let viewForMenuItem = ["lessonsController", "wordsController", "settingsController", "instructionsController"]
    let urlsForMenuItem = ["http://www.infantiq.com/how-early-reader-works-in-app/?utm_source=app", "http://www.infantiq.com/about-us-in-app/?utm_source=app", "http://www.infantiq.com/early-reader-support-in-app/?utm_source=app"]
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var wordsButton: UIButton!
    @IBOutlet weak var lessonsButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    private var _infoPopover : UIPopoverController?

    override func viewDidLoad() {
        super.viewDidLoad()
        var pinkBackgroundImage = UIColor.backgroundImageWithColor(UIColor.applicationPinkColor())
        settingsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        wordsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        lessonsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("shownWhereHelpIsLocated") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shownWhereHelpIsLocated")
            NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "showHelpIsHerePopover", userInfo: nil, repeats: false)
        }
        
        
    }

    @IBAction func didClickMenuButton(sender: UIButton) {
        deselectButtonsInView(view)
        sender.selected = true
        let splitViewController = parentViewController as MainViewController
        splitViewController.showDetailViewControllerWithId(viewForMenuItem[sender.tag])
    }
    
    @IBAction func didClickWebViewerButton(sender: UIButton) {
        deselectButtonsInView(view)
        let splitViewController = parentViewController as MainViewController
        splitViewController.showDetailWebViewController(urlsForMenuItem[sender.tag], title : sender.titleForState(UIControlState.Normal) ?? "?")

    }
    private func deselectButtonsInView(theView : UIView) {
        for view in theView.subviews {
            if let button = view as? UIButton {
                button.selected = false
            } else {
                deselectButtonsInView(view as UIView)
            }
        }
    }
    
    func showHelpIsHerePopover() {
        if view.window == nil {
            // Try again later
            NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: "showHelpIsHerePopover", userInfo: nil, repeats: false)
        } else {
            var popoverContentView = UIView()
            popoverContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
            var label = UILabel()
            label.font = UIFont(name: "OpenSans-Light", size : 17.0)
            label.textColor = UIColor.applicationTextColor()
            label.numberOfLines = 0
            label.text = NSLocalizedString("menu_help_is_here", comment: "")
            let width = CGFloat(450)
            let padding = CGFloat(16)
            let labelSize = label.sizeThatFits(CGSize(width: width - padding, height: CGFloat.max))
            let size = CGSize(width: width, height: labelSize.height + padding)
            popoverContentView.addSubview(label)
            label.center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
            label.bounds = CGRect(x:0,y:0,width:labelSize.width, height: labelSize.height)
            
            let popoverContentViewController = UIViewController()
            popoverContentViewController.view = popoverContentView
            popoverContentViewController.preferredContentSize = size
            _infoPopover = UIPopoverController(contentViewController: popoverContentViewController)
            _infoPopover!.popoverContentSize = size
            _infoPopover!.delegate = self
            _infoPopover!.presentPopoverFromRect(helpButton.frame, inView: helpButton.superview!, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)

        }
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        _infoPopover = nil // let it go
    }
}
