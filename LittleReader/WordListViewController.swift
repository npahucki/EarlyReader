//
//  WordListViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class WordListViewController: UITableViewController,ManagedObjectContextHolder, NSFetchedResultsControllerDelegate, WordListTableHeaderViewDelegate, STCollapseTableViewDelegate {

    var managedContext : NSManagedObjectContext? = nil
    var fetchedResultsController = NSFetchedResultsController()
    
    private var _headerViews = [Int: WordListTableHeaderView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = getFetchedResultController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
    }
    
    private func getFetchedResultController() -> NSFetchedResultsController {
        if let baby = Baby.currentBaby {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            fetchRequest.predicate = NSPredicate(format: "baby = %@",baby)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "wordSet.number", ascending: true),
                NSSortDescriptor(key: "retiredOn", ascending: true),
                NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")
            ]
            fetchRequest.propertiesToFetch = ["wordSet"]
            if let ctx = managedContext {
                return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ctx, sectionNameKeyPath: "wordGroupingKey", cacheName: nil)
            }
        }
        
        return fetchedResultsController
    }
    

    func didClickHeaderButton(sender:WordListTableHeaderView, button: UIButton) {
        if sender.sectionKey == Word.wordAvailableGroupKey() {
            if button == sender.addButton {
                self.performSegueWithIdentifier("showAddWords", sender: self)
            } else if button == sender.editButton {
                if tableView.editing {
                    endEditingAvailableWords()
                } else {
                    startEditingAvailableWords()
                }
            }
        }
    }

    func startEditingAvailableWords() {
        if let headerView = _headerViews.values.filter( {$0.sectionKey == Word.wordAvailableGroupKey()}).array.first {
            headerView.addButton.enabled = false
            // TODO: localize
            headerView.editButton.setTitle("Done", forState: UIControlState.Normal)
            tableView.setEditing(true, animated: true)
        }
    }

    func endEditingAvailableWords() {
        if let headerView = _headerViews.values.filter( {$0.sectionKey == Word.wordAvailableGroupKey()}).array.first {
            headerView.addButton.enabled = true
            // TODO: localize
            headerView.editButton.setTitle("Edit", forState: UIControlState.Normal)
            tableView.setEditing(false, animated: true)
        }
        updateHeaderTextForAllSections()
    }

    
    
    func didCollapseSection(section: Int) {
        // Cancel any editing
        if tableView.editing && _headerViews[section]?.sectionKey == Word.wordAvailableGroupKey() {
            endEditingAvailableWords()
        }

        if let headerView = _headerViews[section] {
            if headerView.sectionKey == Word.wordAvailableGroupKey() {
                headerView.addButton.hidden = true
                headerView.editButton.hidden = true
            }
        }
    }
    
    func didExpandSection(section: Int) {
        if let headerView = _headerViews[section] {
            if headerView.sectionKey == Word.wordAvailableGroupKey() {
                headerView.addButton.hidden = false
                headerView.editButton.hidden = fetchedResultsController.sections![section].numberOfObjects < 1
            }
        }
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
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
        if (type == NSFetchedResultsChangeType.Delete) {
            // Delete row from tableView.
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            updateHeaderTextForAllSections()
        }
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = _headerViews[section] {
            return view
        } else {
            let headerView = NSBundle.mainBundle().loadNibNamed("WordListHeaderView", owner:nil, options:nil)[0] as WordListTableHeaderView;
            _headerViews[section] = headerView
            headerView.delegate = self
            if let sectionKey = fetchedResultsController.sections![section].name {
                headerView.sectionKey = sectionKey
                updateHeaderTextForSection(section)
            }
            return headerView
        }
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    
    func updateHeaderTextForSection(section: Int) {
        if let headerView = _headerViews[section] {
            headerView.titleLabel.text = NSLocalizedString("word_list_" + headerView.sectionKey!, comment : "")
            headerView.detailLabel.text =  NSString(format: NSLocalizedString("word_list_section_number_of_words", comment : "In the word list table, the number of words in the section header"), fetchedResultsController.sections![section].numberOfObjects)
        }
    }

    func updateHeaderTextForAllSections() {
        for section in 0..._headerViews.count {
            updateHeaderTextForSection(section)
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
                // TODO: Needed an added date.
                cell.detailTextLabel!.text = nil; // "Added \(word.activatedOn?.stringWithHumanizedTimeDifference())"
            }
        }
        return cell
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        //tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? AddWordsViewController {
            vc.wordListController = self
        }
    }
    
    func didManuallyAddWordsInString(wordString : String) {
        if let baby = Baby.currentBaby {
            let importer = WordImporter(baby : baby)
            let words = importer.parseWords(wordString)
            if words?.count > 0 {
                let result = importer.importWords(words!)
                if let err = result.error {
                    UIAlertView.showGenericLocalizedErrorMessage("error_msg_words_added")
                    UsageAnalytics.trackError("Could not import manually added words", error: err)
                } else {
                    if result.numberOfWordsAdded > 0 {
                        let title = NSLocalizedString("success_title_generic", comment:"")
                        let msg = NSString(format: NSLocalizedString("msg_words_added", comment:""), result.numberOfWordsAdded)
                        let cancelTitle = NSLocalizedString("uialert_accept_button_title", comment:"")
                        UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle : cancelTitle).show()
                        
                    }
                }
                
            }
        }
    }
   
    
}
