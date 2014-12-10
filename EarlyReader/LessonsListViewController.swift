//
//  LessonHistoryViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData
import UIKit

class LessonsListViewController: UITableViewController, NSFetchedResultsControllerDelegate, LessonStateDelegate,UIPopoverControllerDelegate {
    
    
    let sectionForNextLesson = 0
    let sectionForPreviousLessons = 1
    
    private var fetchedResultsController = NSFetchedResultsController()
    private var _planner : LessonPlanner?
    private var _infoPopover : UIPopoverController?
    private var _startButton : UIButton!
    private var _shouldStartLessonOnPopoverDismiss = false
    
    override func viewDidLoad() {        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(30.0 , target: self, selector: "updateCurrentStateMessages", userInfo: nil, repeats:true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let b = Baby.currentBaby {
            _planner = LessonPlanner(baby: b)
            updateTakenLessons()
            updateCurrentStateMessages()
        }
    }
    
    func updateTakenLessons() {
        if let ctx = Baby.currentBaby?.managedObjectContext {
            if fetchedResultsController.fetchedObjects == nil {
                let fetchRequest = NSFetchRequest(entityName: "LessonLog")
                fetchRequest.predicate = NSPredicate(format: "(baby == %@) AND numberOfWordsViewed >=\(WORDS_PER_WORDSET)",Baby.currentBaby!)
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
                UsageAnalytics.instance.trackError("Could not load the past lessons", error: err)
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
        var cell = self.dequeueReusableCellWithIdentifier("nextLessonCell", forIndexPath: indexPath) as NextLessonTableViewCell
        if let planner = _planner {
            if let baby = Baby.currentBaby {
                let previewText = planner.wordPreviewForNextLesson()
                if previewText.isEmpty {
                    cell.indicateNoMoreWords()
                } else {
                    cell.setWords(previewText)
                    cell.setDueIn(planner.nextLessonDate ?? NSDate())
                    _startButton = cell.startButton
                }
            }
        }
        
        return cell
    }

    func cellForPreviousLessonAtRow(log: LessonLog, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.dequeueReusableCellWithIdentifier("pastLessonCell", forIndexPath: indexPath) as PastLessonTableViewCell
        cell.setLessonLog(log)
        return cell
    }

    // Hack to work around bug. See http://stackoverflow.com/questions/19132908/auto-layout-constraints-issue-on-ios7-in-uitableviewcell
    private func dequeueReusableCellWithIdentifier(cellIdentifier : String, forIndexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: forIndexPath) as UITableViewCell
        
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedAscending: // Less than ios 8
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleBottomMargin
        default:
            break // NOOP
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if sectionForNextLesson == section {
            footerView.backgroundColor = UIColor.whiteColor()
            // A little hackery to work around a sometimes appearing separator.
            let separatorView = UIView(frame: (CGRect(x: tableView.separatorInset.left, y:-1, width: tableView.frame.width - tableView.separatorInset.right * 2 ,height: 1)))
            separatorView.backgroundColor = UIColor.applicationTableCellSelectedBackgroundColor()
            footerView.addSubview(separatorView)
        }
        return footerView
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("LessonsListTableHeaderView", owner:nil, options:nil)[0] as LessonsListTableHeaderView;
        headerView.disclosureButton.addTarget(self, action: "didClickHeaderDiscloseButton:", forControlEvents: .TouchUpInside)
        headerView.disclosureButton.tag = section
        if section == sectionForNextLesson {
            headerView.titleLabel.text = NSLocalizedString("lesson_header_next_lesson",comment: "")
        } else {
            headerView.titleLabel.text = NSLocalizedString("lesson_header_past_lessons",comment: "")
        }
        
        return headerView
    }

    func didClickHeaderDiscloseButton(sender: UIButton) {
        var labelText = ""
        if let planner = _planner {
            if sender.tag == sectionForNextLesson {
                var key : String
                let nextLessonDue = planner.nextLessonDate ?? NSDate()
                if planner.wordPreviewForNextLesson().isEmpty {
                    key = "next_lesson_info_bubble_no_words"
                } else if nextLessonDue.timeIntervalSinceNow <= 0 {
                    key = "next_lesson_info_bubble_ready"
                } else if nextLessonDue.isTomorrow() {
                    key = "next_lesson_info_bubble_tomorrow"
                } else {
                    key = "next_lesson_info_bubble_waiting"
                }
                labelText = NSLocalizedString(key, comment: "")
            } else if sender.tag == sectionForPreviousLessons {
                let lastWeek = NSDate().dateByAddingDays(-7)
                let dailyLessonCompletionRating = planner.calcPerDayConsistencyRating(lastWeek).rating
                if(dailyLessonCompletionRating > 0) {
                    let consistencyRating = Int(dailyLessonCompletionRating * 100)
                    labelText = NSString(format: NSLocalizedString("previous_lesson_info_bubble_with_rating", comment: ""),consistencyRating)
                } else {
                    labelText = NSLocalizedString("previous_lesson_info_bubble_no_lessons", comment: "")
                }
            }
            
            var popoverContentView = UIView()
            popoverContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            var label = UILabel()
            label.font = UIFont(name: "OpenSans-Light", size : 17.0)
            label.textColor = UIColor.applicationTextColor()
            label.numberOfLines = 0
            label.text = labelText
            let labelSize = label.sizeThatFits(CGSize(width: 500 - 40, height: CGFloat.max))
            let size = CGSize(width: 500, height: labelSize.height + 40)
            popoverContentView.addSubview(label)
            label.center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
            label.bounds = CGRect(x:0,y:0,width:labelSize.width, height: labelSize.height)

            let presentationPoint = sender.frame
            let popoverContentViewController = UIViewController()
            popoverContentViewController.view = popoverContentView
            popoverContentViewController.preferredContentSize = size
            _infoPopover = UIPopoverController(contentViewController: popoverContentViewController)
            _infoPopover!.popoverContentSize = size
            _infoPopover!.delegate = self
            _infoPopover!.presentPopoverFromRect(presentationPoint, inView: sender.superview!, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        }
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        _infoPopover = nil // let it go
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }
    
    func updateCurrentStateMessages() {
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let lvc = segue.destinationViewController as? LessonViewController {
            assert(Baby.currentBaby != nil, "Current Baby must be set before a lesson can be started!")
            lvc.lessonPlanner = _planner
            lvc.delegate = self
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "startLesson" && !NSUserDefaults.standardUserDefaults().boolForKey("shownFirstLessonInstruction") {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("lessonInstructionViewController") as LessonInstructionsViewController!
            vc.lessonsListController = self
            vc.preferredContentSize = CGSize(width: 500 , height: 350)
            _infoPopover = UIPopoverController(contentViewController: vc)
            _infoPopover!.popoverContentSize = vc.preferredContentSize
            _infoPopover!.delegate = self
            _infoPopover!.presentPopoverFromRect(_startButton.frame, inView: _startButton.superview!, permittedArrowDirections: UIPopoverArrowDirection.Right, animated: true)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shownFirstLessonInstruction")
            return false
        } else {
            return true
        }
    }
    
    func dismissInstructionsAndStartLesson() {
        if let p = _infoPopover {
            p.dismissPopoverAnimated(true)
            popoverControllerDidDismissPopover(p)
            performSegueWithIdentifier("startLesson", sender: self)
        }
    }
}

