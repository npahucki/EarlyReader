//
//  MenuViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    let viewForMenuItem = [1 : "lessonController", 2 : "wordListController",  3 : "settingsController"]
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var wordsButton: UIButton!
    @IBOutlet weak var lessonsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinkBackgroundImage = backgroundImage()
        settingsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        wordsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
        lessonsButton.setBackgroundImage(pinkBackgroundImage, forState: .Selected)
    }
    
    @IBAction func didClickMenuButton(sender: UIButton) {
        lessonsButton.selected = false
        wordsButton.selected = false
        settingsButton.selected = false

        sender.selected = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier(viewForMenuItem[sender.tag]!) as UIViewController;
        showDetailViewController(vc, sender: self)
    }

    
    // Move to category on image!
    func backgroundImage() -> UIImage {
        var color = UIColorFromRGB(0xf0045a)
        var rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
        UIGraphicsBeginImageContext(rect.size);
        var context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
