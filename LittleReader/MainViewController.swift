//
//  ViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/16/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class MainViewController : UISplitViewController, UISplitViewControllerDelegate, ManagedObjectContextHolder{
    
    var managedContext : NSManagedObjectContext? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Make sure all initial subviews have the context set before they appear.
        for vc in viewControllers {
            if let chvc = vc as? ManagedObjectContextHolder {
                chvc.managedContext = self.managedContext
            }
        }
        
    }
    
    override func viewDidLoad() {
        delegate = self
        preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
        preferredPrimaryColumnWidthFraction = 0.25
        view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        if Baby.currentBaby == nil {
            // Show the dialog to enter a baby. 
            self.performSegueWithIdentifier("showNewChildDialog", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }
    
    override func showDetailViewController(vc: UIViewController!, sender: AnyObject!) {

        if let mochVc = vc as? ManagedObjectContextHolder {
            mochVc.managedContext = self.managedContext
        }

        if(super.respondsToSelector("showDetailViewController:sender:")) {
            super.showDetailViewController(vc, sender:sender)
        } else {
            // IOS 7
            if self.viewControllers.count > 1 {
                self.viewControllers = [self.viewControllers[0],vc]
            } else {
                self.viewControllers = [vc]
            }
        }
    }

}

