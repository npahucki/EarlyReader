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

//    @IBAction func didClickLoadWords(sender: AnyObject) {
//        // TODO: Get from S3, make private call, or use a signed URL that expires waaaaay in the future.
//        loadingWordsIndicator.startAnimating()
//        let url = NSURL(string: "http://s3.amazonaws.com/InfantIQLittleReader/WordSets/en/basic.txt")
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
//                // Called on background thread
//            dispatch_async(dispatch_get_main_queue(),{ () -> Void in
//                if error != nil {
//                    self.loadingWordsIndicator.stopAnimating()
//                    UIAlertView.showLocalizedErrorMessageWithOkButton("msg_error_check_network_try_again", title_key: "error_title_download_word_list")
//                    UsageAnalytics.trackError("Failed to download word list", error: error)
//                } else {
//                    let wordString = NSString(data:data, encoding: NSUTF8StringEncoding)
//                    let words = wordString?.componentsSeparatedByString("\n") as [String]
//                    self.insertWords(words)
//                    UIAlertView.showGenericLocalizedSuccessMessage("msg_success_import_words")
//                    self.loadingWordsIndicator.stopAnimating()
//                }
//            })
//        }
//
//        task.resume()
//    }
//    
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
//    func updateWordCount() {
//        if let ctx = managedContext {
//            let fetchRequest = NSFetchRequest(entityName: "Word")
//            let count = ctx.countForFetchRequest(fetchRequest, error: nil)
//            let title = NSString(format: NSLocalizedString("settings_menu_clear_words",comment : "Settings menu text"), count)
//            self.clearWordsButton.setTitle(title, forState: UIControlState.Normal)
//        }
//    }
//    
//    func insertWords(words : [String]) {
//        if let ctx = managedContext {
//            let importer = WordImporter(managedContext:ctx)
//            let result = importer.importWords(words)
//            if let err = result.error {
//                UsageAnalytics.trackError("Failed to insertWords into CoreData", error: err)
//            } else {
//                if let baby = Baby.currentBaby {
//                    let numSets = baby.wordSets.count > 0 ? baby.wordSets.count : 1
//                    baby.populateWordSets(numSets)
//                    //updateWordCount()
//                }
//            }
//        }
//    }
    



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
    }

    
}
