//
//  MenuViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
@objc
class MenuViewController: UIViewController {

    let viewForMenuItem = ["lessonsController", "wordsController", "settingsController", "instructionsController"]
    let urlsForMenuItem = ["http://www.infantiq.com/how-early-reader-works-in-app/?utm_source=app", "http://www.infantiq.com/about-us-in-app/?utm_source=app", "http://www.infantiq.com/early-reader-support-in-app/?utm_source=app"]
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var wordsButton: UIButton!
    @IBOutlet weak var lessonsButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    private var _bubble : PopoverHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        var pinkBackgroundImage = UIColor.backgroundImageWithColor(UIColor.applicationPinkColor())
        settingsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        wordsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        lessonsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        
        if  NSUserDefaults.checkFlagNotSetWithKey("shownWhereHelpIsLocated") {
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
            _bubble = PopoverHelper()
            _bubble!.pinToView = helpButton
            _bubble!.showToolTipBubble(NSLocalizedString("menu_help_is_here", comment: "")) { () -> () in
                self._bubble = nil
            }
        }
    }
    
}
