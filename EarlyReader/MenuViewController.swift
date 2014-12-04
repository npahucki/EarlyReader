//
//  MenuViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    let viewForMenuItem = ["lessonsController", "wordsController", "settingsController", "instructionsController"]
    let urlsForMenuItem = ["http://infantiq.com/how-early-reader-works/", "http://infantiq.com/about-us/", "http://infantiq.com/early-reader-support/"]
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var wordsButton: UIButton!
    @IBOutlet weak var lessonsButton: UIButton!
    @IBOutlet weak var instructionsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        var pinkBackgroundImage = UIColor.backgroundImageWithColor(UIColor.applicationPinkColor())
        settingsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        wordsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        lessonsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        instructionsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
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
}
