//
//  ViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/16/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class MainViewController : UISplitViewController, UISplitViewControllerDelegate, ManagedObjectContextHolder {
    
    private var _managedContext : NSManagedObjectContext? = nil
    var managedContext : NSManagedObjectContext? {
        get {
            return _managedContext
        }
        set {
            _managedContext = newValue
            for vc in viewControllers {
                if let chvc = vc as? ManagedObjectContextHolder {
                    chvc.managedContext = _managedContext
                }
            }
        }
    }
    
    override func viewDidLoad() {
        delegate = self
        
        view.backgroundColor = UIColor.whiteColor()

//    *** NOT SUPPORTED IN IOS 7!
//        preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
//        preferredPrimaryColumnWidthFraction = 0.25
    
    }
    
    override func viewDidAppear(animated: Bool) {
        if Baby.currentBaby == nil {
                // Show the dialog to enter a baby.
                self.performSegueWithIdentifier("showNewChildDialog", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = _managedContext
        }
        
        if let vc = segue.destinationViewController as? ChildInfoViewController {
            if let ctx = managedContext {
                if let entityDescripition = NSEntityDescription.entityForName("Baby", inManagedObjectContext:ctx) {
                    vc.baby = Baby(entity: entityDescripition, insertIntoManagedObjectContext: ctx)
                }
            }
        }
    }

    func showDetailViewControllerWithId(vcId: String, sender: AnyObject!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier(vcId) as UIViewController;
        showDetailViewControllerForOs(vc, sender: sender)
    }

    private func showDetailViewControllerForOs(vc: UIViewController, sender: AnyObject!) {
        if let mochVc = vc as? ManagedObjectContextHolder {
            mochVc.managedContext = _managedContext
        }

        if(super.respondsToSelector("showDetailViewController:sender:")) {
            showDetailViewController(vc, sender:sender)
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

