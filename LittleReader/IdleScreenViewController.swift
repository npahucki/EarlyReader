//
//  IdleScreenViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class IdleScreenViewController: UIViewController, ManagedObjectContextHolder, LessonStateDelegate {

    var managedContext : NSManagedObjectContext? = nil

    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var auxMessageLabel: UILabel!
    @IBOutlet weak var currentBabyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(30.0 , target: self, selector: "updateWaitBeforeNextLessonMessage", userInfo: nil, repeats:true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateWaitBeforeNextLessonMessage() // Update the time if needed
        if let b = Baby.currentBaby {
            let title = NSLocalizedString("current_baby",comment:"")
            currentBabyLabel.text = title.stringByAppendingString(b.name)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ManagedObjectContextHolder {
            vc.managedContext = self.managedContext
        }
        if "startLesson" == segue.identifier {
            var lvc = segue.destinationViewController as LessonViewController
            lvc.delegate = self;
        }
    }
    
    func updateWaitBeforeNextLessonMessage() {
        if let lastLessonFinished = UserPreferences.lastLessonTakenAt {
            auxMessageLabel.hidden = false
            let nextLessonStart = NSDate(timeInterval: 30.0 * 60.0, sinceDate: lastLessonFinished)
            if(nextLessonStart.timeIntervalSinceNow > 0) {
                auxMessageLabel.text = NSString(format: NSLocalizedString("wait_time_for_next_lesson",comment: ""),  Int(nextLessonStart.timeIntervalSinceNow / 60.0 + 1))
                auxMessageLabel.textColor = UIColor.orangeColor()
                return
            }
        }
        
        auxMessageLabel.text = NSLocalizedString("time_for_next_lesson",comment: "")
        auxMessageLabel.textColor = UIColor.greenColor()
    }
    
    func willStartLesson() {
    }
    
    func didCompleteLesson() {
    }
    

}
