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
        var error: NSError? = nil
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "WordSet")
            //fetchRequest.predicate = NSPredicate(format: "number = %d", argumentArray: [1])
            if let results = ctx.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
                NSLog("%@", results);
                if(results.count > 0) {
                    let wordSet = results[0]
                    textLabel.textColor = UIColor.redColor()
                    self.currentIdx = 1
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.navigationController?.navigationBar.hidden = true
                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    self.currentWords = wordSet.words.allObjects as? [Word]
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "showNextWord", userInfo: nil, repeats: true)
                    
                }
            }

            
//            let fetchRequest = NSFetchRequest(entityName: "Word")
//            //fetchRequest.predicate = NSPredicate(format: "wordSet.number = %d", argumentArray: [1])
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
//            let results = ctx.executeFetchRequest(fetchRequest, error: &error)
        }
        
        if error != nil {
            NSLog("FETCH FAILED: %@",error!);
        }

        
        
    }
    
    
    func resetToDefaultScreen() {
        textLabel.text = "LittleReader"
        textLabel.textColor = UIColor .greenColor()
        self.navigationController?.navigationBar.hidden = false
        self.currentIdx = 0
        self.setNeedsStatusBarAppearanceUpdate()
    }


}

