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
    
    var managedContext : NSManagedObjectContext? = nil
    var fetchedResultsController = NSFetchedResultsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = getFetchedResultController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
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
        if let sections = fetchedResultsController.sections {
            return sections.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as UITableViewCell
        let log = fetchedResultsController.objectAtIndexPath(indexPath) as LessonLog
        // TODO: Localize if we keep this around!
        let duration = NSString(format:"%.01f", log.durationSeconds)
        cell.textLabel.text = "\(log.words) lasted \(duration) seconds"
        cell.detailTextLabel!.text = (log.lessonDate.stringWithHumanizedTimeDifference())
        return cell
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }

}

