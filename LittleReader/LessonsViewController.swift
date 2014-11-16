//
//  IdleScreenViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class LessonsViewController: UIViewController, LessonStateDelegate {

    private var _lessonHistoryController : LessonsListViewController? = nil
    private var _planner : LessonPlanner? = nil
    
    @IBOutlet weak var infoMessageLabel: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let b = Baby.currentBaby {
            _planner = LessonPlanner(baby: b)
            if let vc = _lessonHistoryController {
               vc.baby = Baby.currentBaby
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let historyController = segue.destinationViewController as? LessonsListViewController {
            historyController.baby = Baby.currentBaby
            _lessonHistoryController = historyController
        }
    }
    
    

//    func updateCurrentStateMessage() {
//        if let planner = _planner {
//            
//            if let baby = Baby.currentBaby {
//                let day = planner.dayOfProgram
//                if  planner.numberOfWordSetsForToday < baby.wordSets.count {
//                    infoMessageLabel.text = NSString(format: NSLocalizedString("idle_info_program_day_and_increase_sets",comment: ""), day, planner.numberOfWordSetsForToday)
//                    infoMessageLabel.textColor = UIColor.redColor()
//                } else {
//                    infoMessageLabel.text = NSString(format: NSLocalizedString("idle_info_program_day",comment: ""), day)
//                    infoMessageLabel.textColor = UIColor.greenColor()
//                }
//            
//                let nextLesson = planner.nextLessonDate
//                if nextLesson.timeIntervalSinceNow <= 0 {
//                    auxMessageLabel.text = NSLocalizedString("time_for_next_lesson",comment: "")
//                    auxMessageLabel.textColor = UIColor.greenColor()
//                } else if nextLesson.isTomorrow() {
//                    auxMessageLabel.text = NSLocalizedString("todays_lessons_completed",comment: "")
//                    auxMessageLabel.textColor = UIColor.orangeColor()
//                } else {
//                    auxMessageLabel.text = NSString(format: NSLocalizedString("wait_time_for_next_lesson",comment: ""),
//                        planner.numberOfLessonsRemainingToday,
//                        nextLesson.stringWithHumanizedTimeDifference(false))
//                    auxMessageLabel.textColor = UIColor.orangeColor()
//                }
//            }
//        }
//
//    }
    
    
    // MARK: LessonStateDeletegate methods
    func willStartLesson() {
    }
    
    func didCompleteLesson() {
    }

}
