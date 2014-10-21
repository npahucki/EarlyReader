//
//  IdleScreenViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class IdleScreenViewController: UIViewController, LessonStateDelegate {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var auxMessageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(30.0 , target: self, selector: "updateWaitBeforeNextLessonMessage", userInfo: nil, repeats:true)
    }
    
    override func viewDidAppear(animated: Bool) {
        updateWaitBeforeNextLessonMessage() // Update the time if needed
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
                auxMessageLabel.text = NSString(format: NSLocalizedString("You should wait at least %d minutes before giving the next lesson",comment: ""),  Int(nextLessonStart.timeIntervalSinceNow / 60.0 + 1))
                auxMessageLabel.textColor = UIColor.orangeColor()
                return
            }
        }
        
        auxMessageLabel.text = NSLocalizedString("It's time for the next lesson. Press Start Lesson!",comment: "")
        auxMessageLabel.textColor = UIColor.greenColor()
    }
    
    func willStartLesson() {
    }
    
    func didCompleteLesson() {
    }
    

}
