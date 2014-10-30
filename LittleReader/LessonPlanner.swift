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
    private let _managedObjectContext : NSManagedObjectContext
    private var _numberOfWordsViewed : UInt16 = 0
    private var _lessonStartTime : NSDate? = nil
    
    init(baby : Baby) {
        assert(baby.managedObjectContext != nil, "Expected baby to have a managedObjectContext!")
        self._baby = baby
        self._managedObjectContext = baby.managedObjectContext!
    }

    var lastLessonDate : NSDate? {
        get {
            return UserPreferences.lastLessonTakenAt
        }
    }
    
    var nextLessonDate : NSDate {
        get {
            return calcNextLessonDate()
        }
    }

    var numberOfLessonsPerDay : Int {
        get {
            return countOfLessonsPerDay()
        }
    }

    var numberOfLessonsRemainingToday : Int {
        get {
            return countLessonsRemainingForToday().count
        }
    }

    var numberOfLessonsTakenToday : Int {
        get {
            return countLessonsGivenOnDate(NSDate()).count
        }
    }

    
    
    /// Call to get the next bunch of words to display.
    func startLesson() -> [Word]? {
        _lessonStartTime = NSDate()
        
        // The date when the first lesson was taken
        if UserPreferences.programStartedAt == nil {
            UserPreferences.programStartedAt = _lessonStartTime
        }
        
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
    func finishLesson() {
        assert(_lessonStartTime != nil, "Lesson was never started")
        
        let now = NSDate()
        
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
    }
    
    /// Call to indicate that a word has been viewed.
    func markWordViewed(word : Word) {
        word.lastViewedOn = NSDate()
        word.timesViewed++
        _numberOfWordsViewed++
        // TODO: Add an array of words actually viewed.
    }
    
    private func calcNextLessonDate() -> NSDate {
        var nextLessonDate = NSDate()
        if let lastLessonDate = UserPreferences.lastLessonTakenAt {
            nextLessonDate = NSDate(timeInterval: UserPreferences.lessonReminderInverval, sinceDate:lastLessonDate)
            let result = countLessonsRemainingForToday()
            if let e = result.error {
                UsageAnalytics.trackError("Could not count the lessons remaining today", error: e)
            } else if result.count <= 0 {
                // This means that the lesson was already viewed today, and that the next lesson should be tomorrow
                nextLessonDate =  lastLessonDate.theNextMorning()
            }
        }
        
        return nextLessonDate
    }
    
    private func logLesson(wordSet : WordSet) {
        if let entityDescription = NSEntityDescription.entityForName("LessonLog", inManagedObjectContext:_managedObjectContext) {
            let log = LessonLog(entity: entityDescription, insertIntoManagedObjectContext: _managedObjectContext)
            log.baby = _baby
            log.numberOfWordsViewed = _numberOfWordsViewed
            log.wordSetNumber = wordSet.number
            log.words = ",".join((Array(wordSet.words) as [Word]).map { $0.text })
            log.lessonDate = _lessonStartTime!
            log.durationSeconds = -_lessonStartTime!.timeIntervalSinceNow
            log.totalNumberOfWordSets = UInt16(UserPreferences.numberOfWordSets)
        }
    }
    
    private func findNextWordSet() -> WordSet? {
        var set : WordSet? = nil;

        var error: NSError? = nil
        let fetchRequest = NSFetchRequest(entityName: "WordSet")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedOn", ascending: true)]
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "(baby == %@)",_baby)
        if let results = _managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [WordSet] {
            set = results.count > 0 ? results.first : nil
        }
        
        if error != nil {
            UsageAnalytics.trackError("Error trying to load word set from CoreData", error:error!);
        }
        
        return set;
    }
    
    private func saveUpdatedWordsAndSets() {
        var error : NSError? = nil;
        _managedObjectContext.save(&error)
        if let err = error {
            UsageAnalytics.trackError("Failed to save changed Words and WordSets", error: err)
        }
    }

    private func countOfLessonsPerDay() -> Int {
        return UserPreferences.numberOfWordSets * UserPreferences.numberOfTimesToRepeatEachWordSet
    }
    
    private func countLessonsRemainingForToday() -> (count:Int, error:NSError?) {
        var error: NSError? = nil
        var count : Int = 0
        let now = NSDate()
        
        let result = countLessonsGivenOnDate(now)
        if let err = result.error {
            error = err
        } else {
           count = countOfLessonsPerDay() - result.count
        }
        
        return (count: count, error: error)
    }
    
    private func countLessonsGivenOnDate(date : NSDate) -> (count:Int, error:NSError?) {
        var error: NSError? = nil
        var count : Int = 0
        let fetchRequest = NSFetchRequest(entityName: "LessonLog")
        fetchRequest.predicate = NSPredicate(format: "(baby == %@) AND (lessonDate >= %@) AND (lessonDate <= %@)",_baby, date.startOfDay(), date.endOfDay())
        count = _managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        return (count: count, error: error)
    }

}

