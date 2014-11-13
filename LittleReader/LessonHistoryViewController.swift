//
//  LessonHistoryViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData
import UIKit

class LessonHistoryViewController: UITableViewController,ManagedObjectContextHolder, NSFetchedResultsControllerDelegate {
    
    let sectionForNotifications = 0
    let sectionForNextLesson = 1
    let sectionForPreviousLessons = 2
    
    private var _planner : LessonPlanner? = nil
    var managedContext : NSManagedObjectContext? = nil
    var fetchedResultsController = NSFetchedResultsController()
    var notifications = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = getFetchedResultController()
        fetchedResultsController.delegate = self
        
        var error : NSError? = nil
        fetchedResultsController.performFetch(&error)
        if let err = error {
            NSLog("ERROR LOADING LOGS: %@", err)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(30.0 , target: self, selector: "updateCurrentStateMessages", userInfo: nil, repeats:true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let b = Baby.currentBaby {
            _planner = LessonPlanner(baby: b)
            updateCurrentStateMessages()
        }
    }
    
    func getFetchedResultController() -> NSFetchedResultsController {
        if let ctx = managedContext {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        }
        return fetchedResultsController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "LessonLog")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lessonDate", ascending: false)]
        return fetchRequest
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        assert(fetchedResultsController.sections?.count <= 1,"Unexpected number of sections")
        NSLog("results rows:%d", fetchedResultsController.sections?.count ?? 0);
        return 3 //2 + (fetchedResultsController.sections?.count ?? 0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case sectionForNotifications:
                return notifications.count
            case sectionForNextLesson:
                return 1
            case sectionForPreviousLessons:
                if let sections = fetchedResultsController.sections {
                    return sections[section].numberOfObjects
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
        case sectionForNotifications:
            return cellForNotificationAtIndexPath(indexPath)
        case sectionForNextLesson:
            assert(indexPath.row == 0, "Next lesson should never have more than row 0!")
            return cellForNextLessonAtIndexPath(indexPath)
        case sectionForPreviousLessons:
            let log = fetchedResultsController.objectAtIndexPath(indexPath) as LessonLog
            return cellForPreviousLessonAtRow(log, indexPath: indexPath)
        default:
            assert(false, "Unexpected section \(indexPath.section)")
        }
    }
    
    func cellForNotificationAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as UITableViewCell
        
        
        return cell
    }

    func cellForNextLessonAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("nextLessonCell", forIndexPath: indexPath) as UITableViewCell
        if let planner = _planner {
            if let baby = Baby.currentBaby {
//                let day = planner.dayOfProgram
//                if  planner.numberOfWordSetsForToday < baby.wordSets.count {
//                    infoMessageLabel.text = NSString(format: NSLocalizedString("idle_info_program_day_and_increase_sets",comment: ""), day, planner.numberOfWordSetsForToday)
//                    infoMessageLabel.textColor = UIColor.redColor()
//                } else {
//                    infoMessageLabel.text = NSString(format: NSLocalizedString("idle_info_program_day",comment: ""), day)
//                    infoMessageLabel.textColor = UIColor.greenColor()
//                }
                
                
                let nextLesson = planner.nextLessonDate
                if nextLesson.timeIntervalSinceNow <= 0 {
                    cell.textLabel.text = NSLocalizedString("time_for_next_lesson",comment: "")
                    cell.textLabel.textColor = UIColor.applicationGreenColor()
                    cell.detailTextLabel!.text = planner.wordPreviewForNextLesson()
                } else if nextLesson.isTomorrow() {
                    cell.textLabel.text = NSLocalizedString("todays_lessons_completed",comment: "")
                    cell.textLabel.textColor = UIColor.applicationPinkColor()
                    cell.detailTextLabel!.text = NSLocalizedString("todays_lessons_completed_detail",comment: "")
                } else {
                    cell.textLabel.text = NSString(format: NSLocalizedString("wait_time_for_next_lesson",comment: ""),
                        nextLesson.stringWithHumanizedTimeDifference(false))
                    cell.textLabel.textColor = UIColor.applicationTextColor()
                    cell.detailTextLabel!.text = planner.wordPreviewForNextLesson()
                }
            }
        }

        
        
        
        return cell
    }

    func cellForPreviousLessonAtRow(log: LessonLog, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("previousLessonCell", forIndexPath: indexPath) as UITableViewCell
        // TODO: Localize
        let duration = NSString(format:"%.01f", log.durationSeconds)
        cell.textLabel.text = "LESSON TAKEN \(log.lessonDate.stringWithHumanizedTimeDifference()) lasted \(log.durationSeconds) seconds"
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



}

