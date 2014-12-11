//
//  WordListViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

class WordListViewController: UITableViewController,ManagedObjectContextHolder, NSFetchedResultsControllerDelegate, WordListTableHeaderViewDelegate, STCollapseTableViewDelegate {

    var managedContext : NSManagedObjectContext? = nil
    var fetchedResultsController = NSFetchedResultsController()
    
    

    enum WordSection : Int {
        case AvailableWords = 0
        case InSetWords = 1
        case RetiredWords = 2
    }
    
    private var _sectionHeaderViews = [WordSection : WordListTableHeaderView]()
    private var _sectionObjects = [WordSection:[Word]]()
    private var _deletedIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    private func reloadTable() {
        _sectionObjects.removeAll(keepCapacity: true)
        tableView.reloadData()
        updateHeaderTextForAllSections()
    }
    
    private func wordAtIndexPath(indexPath : NSIndexPath) -> Word {
        let wordsInSection = wordsInSectionNumber(indexPath.section)
        return wordsInSection[indexPath.row]
    }
    
    private func wordsInSectionNumber(sectionNumber : Int) -> [Word] {
        let wordSection = WordSection(rawValue: sectionNumber)!
        if let words = _sectionObjects[wordSection] {
            return words
        } else {
            let words = fetchResultsForSection(wordSection)
            _sectionObjects[wordSection] = words
            return words
        }
    }
    
    private func fetchResultsForSection(section : WordSection) -> [Word] {
        var words : [Word] = [Word]()
        if let ctx = managedContext {
            var error : NSError?
            if let ws = ctx.executeFetchRequest(fetchRequestForSection(section), error: &error) as? [Word] {
                words = ws
            }
            if let e = error {
                UsageAnalytics.instance.trackError("Failed to load words in section \(section)", error: e)
            }
        }
        return words
    }
    
    private func fetchRequestForSection(section : WordSection) -> NSFetchRequest {
        if let baby = Baby.currentBaby {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            switch(section) {
            case .AvailableWords:
                fetchRequest.predicate = NSPredicate(format: "baby = %@ AND retiredOn = NULL && wordSet = NULL",baby)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")]
            case .InSetWords:
                fetchRequest.predicate = NSPredicate(format: "baby = %@ AND wordSet != NULL",baby)
                fetchRequest.propertiesToFetch = ["wordSet"]
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(key: "wordSet.number", ascending: true),
                    NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")
                ]
            case .RetiredWords:
                fetchRequest.predicate = NSPredicate(format: "baby = %@ AND retiredOn != NULL",baby)
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(key: "retiredOn", ascending: true),
                    NSSortDescriptor(key: "text", ascending: true, selector: "localizedCaseInsensitiveCompare:")
                ]
            }
            return fetchRequest
        } else {
            return NSFetchRequest()
        }
    }
  
    private func sectionKeyForSection(wordSection : WordSection) -> String {
        switch (wordSection) {
        case .AvailableWords:
            return Word.wordAvailableGroupKey()
        case .InSetWords:
            return Word.wordInSetGroupKey()
        case .RetiredWords:
            return Word.wordRetiredGroupKey()
        }
    }

    private func updateHeaderTextInSectionNumber(section: Int) {
        let wordSection = WordSection(rawValue: section)!
        if let headerView = _sectionHeaderViews[wordSection] {
            let key = sectionKeyForSection(wordSection)
            headerView.titleLabel.text = NSLocalizedString("word_list_" + key, comment : "")
            headerView.detailLabel.text =  NSString(format: NSLocalizedString("word_list_section_number_of_words", comment : "In the word list table, the number of words in the section header"), self.tableView(tableView, numberOfRowsInSection: section))
        }
    }
    
    private func updateHeaderTextForAllSections() {
        for section in 0..._sectionHeaderViews.count - 1 {
            updateHeaderTextInSectionNumber(section)
        }
    }

    private func startEditingAvailableWords() {
        if let headerView = _sectionHeaderViews[.AvailableWords] {
            headerView.editButton.setTitle(NSLocalizedString("words_editing_done_button",comment:"Text shown when editing the word list"), forState: UIControlState.Normal)
            headerView.addButton.hidden = true
            tableView.setEditing(true, animated: true)
        }
    }
    
    private func endEditingAvailableWords() {
        if let headerView = _sectionHeaderViews[.AvailableWords] {
            headerView.addButton.hidden = false
            headerView.editButton.setTitle(NSLocalizedString("words_editing_edit_button",comment:"Text shown when editing the word list"), forState: UIControlState.Normal)
            tableView.setEditing(false, animated: true)
        }
        updateHeaderTextForAllSections()
    }
    
    func didClickHeaderButton(sender:WordListTableHeaderView, button: UIButton) {
        if sender.wordSection == WordSection.AvailableWords {
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

    /// MARK: STCollapseTableViewDelegate
    
    func didCollapseSection(section: Int) {
        // Cancel any editing
        if tableView.editing {
            endEditingAvailableWords()
        }
        if let headerView = _sectionHeaderViews[WordSection(rawValue: section)!] {
            if headerView.wordSection == .AvailableWords {
                headerView.editButton.hidden = true
            }
        }
    }
    
    func didExpandSection(section: Int) {
        if let headerView = _sectionHeaderViews[WordSection(rawValue: section)!] {
            if headerView.wordSection == .AvailableWords {
                headerView.addButton.hidden = false
                headerView.editButton.hidden = tableView(tableView, numberOfRowsInSection: section) < 1
            }
        }
    }
    
    /// MARK: UITableViewDelegate methods

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // When the deletion animaiton is complete..this will get fired. 
        if _deletedIndexPath == indexPath {
            _deletedIndexPath = nil
            reloadTable()
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let word = wordAtIndexPath(indexPath)
            UsageAnalytics.instance.trackWordsDeleted([word])
            var wordSet = word.wordSet
            self.managedContext?.deleteObject(word)
            self.managedContext?.save(nil)
            if wordSet != nil {
                wordSet!.fill()
            }
            
            _sectionObjects[WordSection(rawValue: indexPath.section)!]?.removeAtIndex(indexPath.row)
            _deletedIndexPath = indexPath
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

    /// MARK: UITableViewDataSource methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsInSectionNumber(section).count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let wordSection = WordSection(rawValue: section)!
        if let view = _sectionHeaderViews[wordSection] {
            return view
        } else {
            let headerView = NSBundle.mainBundle().loadNibNamed("WordListHeaderView", owner:nil, options:nil)[0] as WordListTableHeaderView;
            _sectionHeaderViews[wordSection] = headerView
            headerView.delegate = self
            headerView.wordSection = wordSection
            updateHeaderTextInSectionNumber(section)
            
            if wordSection == .AvailableWords {
                headerView.addButton.hidden = false
            }
            
            return headerView
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("wordCell", forIndexPath: indexPath) as UITableViewCell
        let word = wordAtIndexPath(indexPath)
        cell.textLabel!.text = word.text
        // TODO: Localize!
        if (word.wordSet != nil) {
            if let viewedOn = word.lastViewedOn {
                cell.detailTextLabel!.text = NSString(format: NSLocalizedString("words_details_in_set_with_last_viewed_on_date", comment:""), word.timesViewed, viewedOn.stringWithHumanizedTimeDifference())
            } else {
                cell.detailTextLabel!.text = NSString(format: NSLocalizedString("words_details_in_set", comment:""), word.timesViewed)
            }
        } else {
            if let date = word.retiredOn {
                cell.detailTextLabel!.text = NSString(format: NSLocalizedString("words_details_retired", comment:""), date.stringWithHumanizedTimeDifference())
            } else {
                cell.detailTextLabel!.text = NSString(format: NSLocalizedString("words_details_available", comment:""), word.addedOn.stringWithHumanizedTimeDifference())
                #if DEBUG
                    cell.detailTextLabel!.text = cell.detailTextLabel!.text! + ". Import Order \(word.importOrder)"
                #endif

            }
        }
        return cell
    }

    
    // Unfortunately, this causes crashes! See http://w3facility.org/question/cell-animation-stop-fraction-must-be-greater-than-start-fraction/
//    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView()
//        footerView.backgroundColor = UIColor.whiteColor()
//        // A little hackery to work around a sometimes appearing separator.
//        let separatorView = UIView(frame: (CGRect(x: tableView.separatorInset.left, y:-1, width: tableView.frame.width - tableView.separatorInset.right * 2 ,height: 1)))
//        separatorView.backgroundColor = UIColor.applicationTableCellSelectedBackgroundColor()
//        footerView.addSubview(separatorView)
//        return footerView
//    }
    
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
                    UsageAnalytics.instance.trackError("Could not import manually added words", error: err)
                } else {
                    if result.numberOfWordsAdded > 0 {
                        UsageAnalytics.instance.trackWordsAdded(words!)
                        baby.populateWordSets(baby.wordSets.count,numberOfWordsPerSet: WORDS_PER_WORDSET)
                        reloadTable()
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
