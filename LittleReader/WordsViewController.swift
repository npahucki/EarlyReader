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

//    @IBAction func didClickClearWords(sender: AnyObject) {
//        if let ctx = managedContext {
//            let fetchRequest = NSFetchRequest(entityName: "Word")
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
//            fetchRequest.includesPropertyValues = false
//
//            var error : NSError? = nil;
//            let words = ctx.executeFetchRequest(fetchRequest, error: &error)
//            if error == nil {
//                for word in words as [Word] {ctx.deleteObject(word)}
//                ctx.save(&error)
//            }
//
//            if let err = error {
//                UIAlertView.showGenericLocalizedErrorMessage("msg_error_delete_words")
//                UsageAnalytics.trackError("Could not delete words", error: err)
//            } else {
//                //self.updateWordCount()
//                UIAlertView.showGenericLocalizedSuccessMessage("msg_success_delete_words")
//            }
//        }
//    }
//    
//    
//    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }

    
}
