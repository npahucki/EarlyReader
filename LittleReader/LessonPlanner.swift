//
//  LessonPlanner.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData

/// Encapsulates the logic for determining which words to show and for how many times.
class LessonPlanner {

    private var _currentWordSet : WordSet? = nil
    private let _baby : Baby
    private var _numberOfWordsViewed : UInt16 = 0
    private var _lessonStartTime : NSDate? = nil
    
    init(baby : Baby) {
        self._baby = baby
    }
    
    
    /// Call to get the next bunch of words to display.
    func startLesson() -> [Word]? {
        _lessonStartTime = NSDate()
        var words : [Word]? = nil
        if let wordSet = findNextWordSet() {
            _currentWordSet = wordSet
            words = (wordSet.words.allObjects as [Word])
            words!.sort {(_,_) in arc4random() % 2 == 0}
        }
        
        return words
    }

    /// Call to indicate that the lesson has been completed
    /// Returns the date/time the next lesson should be done
    func finishLesson() -> NSDate {
        assert(_lessonStartTime != nil, "Lesson was never started")
        
        let now = NSDate()
        var nextLessonDate = NSDate(timeIntervalSinceNow:  UserPreferences.lessonReminderInverval)
        
        if let wordSet = _currentWordSet {
            logLesson(wordSet)
            wordSet.lastViewedOn = now
            var retireResult = wordSet.retireOldWord()
            var fillResult = wordSet.fill()
            saveUpdatedWordsAndSets()
            UserPreferences.lastLessonTakenAt = now
            if let e = retireResult.error {
                UsageAnalytics.trackError("Could not retire words in word set", error: e)
            }
            if let e = fillResult.error {
                UsageAnalytics.trackError("Could not fill words in word set", error: e)
            }
        }

        // TODO: Need to check a log table for this!
//        if let nextWordSet = findNextWordSet() {
//            if let lastViewedOn = nextWordSet.lastViewedOn {
//                if lastViewedOn.isToday() {
//                    // This means that the lesson was already viewed today, and that the next lesson should be tomorrow
//                    nextLessonDate = lastViewedOn.theNextMorning()
//                }
//            }
//        }
        
        
        return nextLessonDate
    }
    
    /// Call to indicate that a word has been viewed.
    func markWordViewed(word : Word) {
        word.lastViewedOn = NSDate()
        word.timesViewed++
        _numberOfWordsViewed++
    }
    
    private func logLesson(wordSet : WordSet) {
        if let ctx = _baby.managedObjectContext {
            if let entityDescription = NSEntityDescription.entityForName("LessonLog", inManagedObjectContext:ctx) {
                let log = LessonLog(entity: entityDescription, insertIntoManagedObjectContext: ctx)
                log.numberOfWordsViewed = _numberOfWordsViewed
                log.wordSetNumber = wordSet.number
                log.words = ",".join((Array(wordSet.words) as [Word]).map { $0.text })
                log.lessonDate = _lessonStartTime!
                log.durationSeconds = -_lessonStartTime!.timeIntervalSinceNow
            }
        }
    }
    
    private func findNextWordSet() -> WordSet? {
        var set : WordSet? = nil;
        assert(_baby.managedObjectContext != nil, "Baby has no managedObjectContext!");

        if let ctx = _baby.managedObjectContext {
            var error: NSError? = nil
            let fetchRequest = NSFetchRequest(entityName: "WordSet")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "(baby == %@)",_baby)
            if let results = ctx.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
                set = results.count > 0 ? results.first : nil
            }
            
            if error != nil {
                UsageAnalytics.trackError("Error trying to load word set from CoreData", error:error!);
            }
        }
        
        return set;
    }
    
    private func saveUpdatedWordsAndSets() {
        assert(_baby.managedObjectContext != nil, "Baby has no managedObjectContext!");
        if let ctx = _baby.managedObjectContext {
            var error : NSError? = nil;
            ctx.save(&error)
            if let err = error {
                UsageAnalytics.trackError("Failed to save changed Words and WordSets", error: err)
            }
        }
    }

}

