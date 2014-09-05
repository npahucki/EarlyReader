//
//  ViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 8/16/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData

class ViewController: UIViewController, UIAlertViewDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var textLabel: UILabel!

    private var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    private var timer : NSTimer?
    private var currentIdx  = 0
    private var currentWords : [Word]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont.systemFontOfSize(500)
        self.resetToDefaultScreen()
        //self.importWords()
    }

    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        let count = fetchedResultController.sections[0].numberOfObjects
        for var i : Int = 0; i < count; i++ {
            let indexPath = NSIndexPath(index: i)
            let word = fetchedResultController.objectAtIndexPath(indexPath) as Word
            NSLog("WORD ID: %@, TEXT: %@", word.objectID, word.text)
        }
    }
    


    func showNextWord() {
        if currentIdx < self.currentWords?.count {
            var animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade;
            animation.duration = 0.25;
            textLabel.layer.addAnimation(animation, forKey: kCATransitionFade)
            
            let word = self.currentWords![self.currentIdx++]
            textLabel.text = word.text
            textLabel.setNeedsUpdateConstraints();
            textLabel.setNeedsLayout();
        } else {
            // Stop the timer
            if let t = timer {
                t.invalidate();
                timer = nil;
                self.resetToDefaultScreen()
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.currentIdx > 0
    }
    
    @IBAction func didClickStartLesson(sender: UIBarButtonItem) {
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        var error: NSError? = nil
        fetchedResultController.performFetch(nil)
        if error == nil {
            textLabel.textColor = UIColor.redColor()
            self.currentIdx = 1
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController.navigationBar.hidden = true
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            // TODO: Load word set from DB!
            self.currentWords = fetchedResultController.fetchedObjects as? [Word]
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "showNextWord", userInfo: nil, repeats: true)
        } else {
            NSLog("FETCH FAILED: %@",error!);
        }
    }
    
    func getFetchedResultController() -> NSFetchedResultsController {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Word")
        //fetchRequest = [NSPredicate predicateWithFormat:@"enity.name = Blah"];
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func resetToDefaultScreen() {
        textLabel.text = "LittleReader"
        textLabel.textColor = UIColor .greenColor()
        self.navigationController.navigationBar.hidden = false
        self.currentIdx = 0
        self.setNeedsStatusBarAppearanceUpdate()
    }


}

