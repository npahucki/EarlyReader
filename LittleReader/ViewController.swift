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

// TODO: 
// 1) Each day: Retire oldest word after showing for some amount of time.
// 3) Shuffle word set order? (look in book to see if this is required)
// 3) Play next word set 
// 4) Describe a time to play next word set

class ViewController: UIViewController, UIAlertViewDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var textLabel: UILabel!

    private var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    private var timer : NSTimer?
    private var currentIdx  = 0
    private var currentWords : [Word]?
    private var currentWordSet : WordSet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont.systemFontOfSize(500)
        resetToDefaultScreen()
    }


    func showNextWord() {
        currentIdx++
        setNeedsStatusBarAppearanceUpdate()
        if currentIdx < self.currentWords?.count {
            var animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade;
            animation.duration = 0.25;
            textLabel.layer.addAnimation(animation, forKey: kCATransitionFade)
            
            let word = self.currentWords![self.currentIdx]
            word.lastViewedOn = NSDate()
            textLabel.text = word.text
            textLabel.setNeedsUpdateConstraints();
            textLabel.setNeedsLayout();
            timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "showNextWord", userInfo: nil, repeats: false)
        } else {
            // Stop the timer
            if let t = timer {
                t.invalidate();
                timer = nil;
            }
            retireWordsInCurrentWordSet()
            saveUpdatedWordsAndSets()
            resetToDefaultScreen()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.currentIdx >= 0
    }
    
    @IBAction func didClickStartLesson(sender: UIBarButtonItem) {
        var error: NSError? = nil
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "WordSet")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
            fetchRequest.fetchLimit = 1
            //fetchRequest.predicate = NSPredicate(format: "number = %d", argumentArray: [1])
            if let results = ctx.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
                NSLog("%@", results);
                if(results.count > 0) {
                    // TODO: Pick next word set
                    currentWordSet = results[0]
                    currentWords = (currentWordSet!.words.allObjects as [Word])
                    currentWords!.sort {(_,_) in arc4random() % 2 == 0}
                    textLabel.text = ""
                    textLabel.textColor = UIColor.redColor()
                    navigationController?.navigationBar.hidden = true
                    showNextWord()
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
        navigationController?.navigationBar.hidden = false
        currentIdx = -1
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func saveUpdatedWordsAndSets() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let ctx = appDelegate.managedObjectContext {
            var error : NSError? = nil;
            ctx.save(&error)
            if let err = error {
                NSLog("Failed to save chnaged Words and WordSets",err)
            }
        }
    }
    
    func retireWordsInCurrentWordSet() {
        if let wordSet = currentWordSet {
            wordSet.lastViewedOn = NSDate()
            // TODO: Swapping logic here!
        }
    }

}

