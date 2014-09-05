//
//  SettingsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 9/5/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


//    func importWords() {
//        let words = ["milk", "page", "rain", "sofa", "bread"]
//        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        let managedObjectContext = appDelegate.managedObjectContext
//        let entityDescripition = NSEntityDescription.entityForName("Word", inManagedObjectContext:managedObjectContext)
//        for w in words {
//            let word = Word(entity: entityDescripition, insertIntoManagedObjectContext: managedObjectContext)
//            word.text = w
//        }
//        
//        var error: NSError? = nil
//        managedObjectContext?.save(&error)
//        if error == nil {
//            NSLog("Words Saved")
//        } else {
//            NSLog("FAILED: %@",error!);
//        }
//        
//    }
    
}
