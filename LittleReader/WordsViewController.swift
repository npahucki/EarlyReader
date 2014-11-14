//
//  WordsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/14/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class WordsViewController: UIViewController, ManagedObjectContextHolder {

    var managedContext : NSManagedObjectContext? = nil

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }

    
}
