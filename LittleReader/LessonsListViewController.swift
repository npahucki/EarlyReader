//
//  LessonHistoryViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData
import UIKit

// TODO:
/*
//                let day = planner.dayOfProgram
//                if  planner.numberOfWordSetsForToday < baby.wordSets.count {
//                    infoMessageLabel.text = NSString(format: NSLocalizedString("idle_info_program_day_and_increase_sets",comment: ""), day, planner.numberOfWordSetsForToday)
//                    infoMessageLabel.textColor = UIColor.redColor()
//                } else {
//                    infoMessageLabel.text = NSString(format: NSLocalizedString("idle_info_program_day",comment: ""), day)
//                    infoMessageLabel.textColor = UIColor.greenColor()
//                }

*/

class LessonsListViewController: UITableViewController, NSFetchedResultsControllerDelegate, LessonStateDelegate {
    
    
    let sectionForNextLesson = 0
    let sectionForPreviousLessons = 1
    
    var baby : Baby?
    private var fetchedResultsController = NSFetchedResultsController()
    private var _planner : LessonPlanner?

    override func viewDidLoad() {
        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(30.0 , target: self, selector: "updateCurrentStateMessages", userInfo: nil, repeats:true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let b = baby {
            _planner = LessonPlanner(baby: baby!)
            updateTakenLessons()
            updateCurrentStateMessages()
        }
    }
    
    func updateTakenLessons() {
        if let ctx = baby?.managedObjectContext {
            if fetchedResultsController.fetchedObjects == nil {
                let fetchRequest = NSFetchRequest(entityName: "LessonLog")
                fetchRequest.predicate = NSPredicate(format: "(baby == %@) AND numberOfWordsViewed >=\(WORDS_PER_WORDSET)",baby!)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lessonDate", ascending: false)]
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                    managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController.delegate = self
            }

            var error : NSError? = nil
            if fetchedResultsController.performFetch(&error) {
                tableView.reloadData()
            }
            
            if let err = error {
                UsageAnalytics.trackError("Could not load the past lessons", error: err)
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        assert(fetchedResultsController.sections?.count <= 1,"Unexpected number of sections")
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case sectionForNextLesson:
                return 1
            case sectionForPreviousLessons:
                if let sections = fetchedResultsController.sections {
                    return sections[0].numberOfObjects
                } else {
                    return 0
                }
            default:
                assert(false,"Unexpected section number \(section)")
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case sectionForNextLesson:
            assert(indexPath.row == 0, "Next lesson should never have more than row 0!")
            return cellForNextLessonAtIndexPath(indexPath)
        case sectionForPreviousLessons:
            // Need to remake the index path, other wise fails because the section is wrong 
            let log = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as LessonLog
            return cellForPreviousLessonAtRow(log, indexPath: indexPath)
        default:
            assert(false, "Unexpected section \(indexPath.section)")
            return UITableViewCell() // needed for compiler
        }
    }

    func cellForNextLessonAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("nextLessonCell", forIndexPath: indexPath) as NextLessonTableViewCell
        if let planner = _planner {
            if let baby = Baby.currentBaby {
                cell.setWords(planner.wordPreviewForNextLesson())
                cell.setDueIn(planner.nextLessonDate ?? NSDate())
            }
        }
        
        return cell
    }

    func cellForPreviousLessonAtRow(log: LessonLog, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("previousLessonCell", forIndexPath: indexPath) as UITableViewCell
        // TODO: Localize
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        let duration = formatter.stringFromNumber(log.durationSeconds)!
        cell.textLabel.text = "LESSON TAKEN \(log.lessonDate.stringWithHumanizedTimeDifference()) lasted \(duration) seconds"
        cell.detailTextLabel!.text = log.words
        return cell
    }
    
    // Hack to not see empty rows
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
    
    func updateCurrentStateMessages() {
        self.tableView.reloadData()
        
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
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let lvc = segue.destinationViewController as? LessonViewController {
            assert(Baby.currentBaby != nil, "Current Baby must be set before a lesson can be started!")
            lvc.lessonPlanner = _planner
            lvc.delegate = self;
        }
    }
    
    func willStartLesson() {
        if let parent = parentViewController as? LessonStateDelegate {
            parent.willStartLesson()
        }
    }
    
    func didCompleteLesson() {
        updateTakenLessons()
        updateCurrentStateMessages()
        if let parent = parentViewController as? LessonStateDelegate {
            parent.didCompleteLesson()
        }
    }
    
    func didAbortLesson() {
        didCompleteLesson()
    }

}

