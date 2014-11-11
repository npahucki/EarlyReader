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
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
        self.preferredPrimaryColumnWidthFraction = 0.20
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
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }
}

