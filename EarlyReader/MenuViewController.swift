//
//  MenuViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    let viewForMenuItem = [1 : "lessonsController", 2 : "wordsController",  3 : "settingsController"]
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var wordsButton: UIButton!
    @IBOutlet weak var lessonsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinkBackgroundImage = UIColor.backgroundImageWithColor(UIColor.applicationPinkColor())
        settingsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        wordsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        lessonsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
    }
    
    @IBAction func didClickMenuButton(sender: UIButton) {
        lessonsButton.selected = false
        wordsButton.selected = false
        settingsButton.selected = false

        sender.selected = true
        
        let splitViewController = parentViewController as MainViewController;
        splitViewController.showDetailViewControllerWithId(viewForMenuItem[sender.tag]!, sender: self)
    }
}
