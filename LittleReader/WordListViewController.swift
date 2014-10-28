//
//  WordListViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class WordListViewController: UITableViewController,ManagedObjectContextHolder, NSFetchedResultsControllerDelegate {

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
            fetchedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: ctx, sectionNameKeyPath: "wordSetNumber", cacheName: nil)
        }
        return fetchedResultsController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "wordSet.number", ascending: false),
            NSSortDescriptor(key: "retiredOn", ascending: false),
            NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")
        ]
        fetchRequest.propertiesToFetch = ["wordSet"]
        return fetchRequest
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
                return sections.count
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let word = self.fetchedResultsController.objectAtIndexPath(indexPath) as Word
            var wordSet = word.wordSet
            self.managedContext?.deleteObject(word)
            self.managedContext?.save(nil)
            if wordSet != nil {
                wordSet!.fill()
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let n = fetchedResultsController.sections![section].name.toInt() {
            if(n == -1) {
                return NSLocalizedString("not_in_set",comment: "Title header section for words not belonging to any set")
            } else {
                return NSString(format:NSLocalizedString("word_set_number",comment: "Title header for words in a word set"), n + 1)
            }
        } else {
            return "??"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("wordCell", forIndexPath: indexPath) as UITableViewCell
        let word = fetchedResultsController.objectAtIndexPath(indexPath) as Word
        cell.textLabel.text = word.text
        // TODO: Localize!
        if (word.wordSet != nil) {
            if let viewedOn = word.lastViewedOn {
                cell.detailTextLabel!.text = NSString(format: "View %d times, last time was %@", word.timesViewed, viewedOn.stringWithHumanizedTimeDifference())
            } else {
                cell.detailTextLabel!.text = NSString(format: "View %d times", word.timesViewed)
            }
        } else {
            if let date = word.retiredOn {
                cell.detailTextLabel!.text = NSString(format: " Retired %@", date.stringWithHumanizedTimeDifference())
            } else {
                cell.detailTextLabel!.text = "In reserve tank"
            }
            
        }
        return cell
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.reloadData()
    }

    
    
}
