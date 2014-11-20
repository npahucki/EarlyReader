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
public class LessonPlanner {
    
    private var _currentWordSet : WordSet? = nil
    private let _baby : Baby
    private let _managedObjectContext : NSManagedObjectContext
    private var _wordsViewedInLesson = NSMutableSet()
    private var _lessonStartTime : NSDate? = nil
    
    var managedContext : NSManagedObjectContext {
        get {
            return _managedObjectContext
        }
    }
    
    public init(baby : Baby) {
        assert(baby.managedObjectContext != nil, "Expected baby to have a managedObjectContext!")
        self._baby = baby
        self._managedObjectContext = baby.managedObjectContext!
    }

    public var numberOfWordsSeenDuringCurrentLesson : Int {
        get {
            return _wordsViewedInLesson.count
        }
    }
    
    public var firstLessonDate : NSDate? {
        get {
            let results = findLessonDate(true)
            if let e = results.error {
                UsageAnalytics.trackError("Could not calculate the fist lesson date", error: e)
            }
            return results.date
        }
    }

    
    public var lastLessonDate : NSDate? {
        get {
            let results = findLessonDate(false)
            if let e = results.error {
                UsageAnalytics.trackError("Could not calculate the last lesson date", error: e)
            }
            return results.date
        }
    }
    
    public var nextLessonDate : NSDate {
        get {
            let results =  calcNextLessonDate()
            if let e = results.error {
                UsageAnalytics.trackError("Could not calculate the next lesson date", error: e)
            }
            return results.date
        }
    }
    
    public var numberOfLessonsPerDay : Int {
        get {
            if let wordSets = _baby.wordSets {
                return wordSets.count * UserPreferences.numberOfTimesToRepeatEachWordSet
            } else {
                return 0
            }
        }
    }
    
    public var numberOfLessonsRemainingToday : Int {
        get {
            let results = countLessonsRemainingForToday()
            if let e = results.error {
                UsageAnalytics.trackError("Error calculating count of lessons remaining today", error: e)
            }
            return results.count
        }
    }
    
    public var numberOfLessonsTakenToday : Int {
        get {
            let results = countLessonsGivenOnDate(NSDate())
            if let e = results.error {
                UsageAnalytics.trackError("Error calculating count of lessons taken today", error: e)
            }
            return results.count
        }
    }
    
    public var numberOfWordSetsForToday : Int {
        get {
            /*
            Day 1:
            5 words in a single set, repeated 3 times in a day.
            Day 2:
            Repeat the first set 3 times, add a set of 5 words, repeat 3 times a day. (It’s not clear if you should intermingle or do all 3 repetitions of a single set)
            Day 3-7:
            Repeat all 3  sets 3 times a day.
            
            'When the system is working smoothly’ - give option to add in two mores sets?
            
            Day 8
            Repeat the first 3 sets set 3 times a day, add a new set.
            Day 9-15
            Repeat all 4 sets set 3 times a day.
            Day 16
            Repeat all 4 sets set 3 times a day, add a new set
            Day 17 onward
            Repeat all 5 sets 3 times a day each. All the while, the retirement process is running every day.
            */
            
            switch(self.dayOfProgram) {
            case 1:
                return 1
            case 2:
                return 2
            case 3-7:
                return 3
            case 8-15:
                return 4
            default:
                return 5
            }
        }
    }
    
    /// Returns the day of the program. This depends on when the program was started and how many days the program has been used.
    /// If you Start on 10/10/14 for example, then on 10/11/14 is Day 2. If you skip a day (the 12th) and come back on
    /// 10/13/14, then this is Day 3. If you skip a week then come back on 10/20/14, this is Day 4.
    public var dayOfProgram : Int {
        get {
            let results = calcCurrentUseDay()
            if let e = results.error {
                UsageAnalytics.trackError("Error calculating day of program", error: e)
            }
            return results.day
        }
    }

    public func wordPreviewForNextLesson() -> [Word] {
        if let wordSet = findNextWordSet() {
            return (wordSet.words.allObjects as [Word])
        } else {
            return [Word]()
        }
    }
    
    public func numberOfWordsLesson() -> Int {
        if let wordSet = findNextWordSet() {
            return wordSet.words.count
        } else {
            return 0
        }
    }
    
    /// Call to get the next bunch of words to display.
    public func startLesson() -> [Word]? {
        assert(_lessonStartTime == nil, "Lesson already started")
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
    public func finishLesson() {
        assert(_lessonStartTime != nil, "Lesson was never started")
        
        let now = NSDate()
        
        if let wordSet = _currentWordSet {
            logLesson(wordSet)
            if _wordsViewedInLesson.count < wordSet.words.count {
                // Lesson was abandoned
            } else {
                // Lesson fully completed
                wordSet.lastViewedOn = now
                var retireResult = wordSet.retireOldWord()
                var fillResult = wordSet.fill()
                saveUpdatedWordsAndSets()
                if let e = retireResult.error {
                    UsageAnalytics.trackError("Could not retire words in word set", error: e)
                }
                if let e = fillResult.error {
                    UsageAnalytics.trackError("Could not fill words in word set", error: e)
                }
            }
        }
        
        // Reset for resuse 
        _currentWordSet = nil
        _wordsViewedInLesson.removeAllObjects()
        _lessonStartTime = nil
    }
    
    /// Call to indicate that a word has been viewed.
    public func markWordViewed(word : Word) {
        word.lastViewedOn = NSDate()
        word.timesViewed++
        _wordsViewedInLesson.addObject(word)
    }
    
    private func calcNextLessonDate() -> (date : NSDate, error: NSError?) {
        var nextLessonDate = NSDate()
        var error : NSError? = nil
        
        let lastLessonResult = findLessonDate(false)
        if let e = lastLessonResult.error {
            error = e
        } else {
            if let lastLessonDate = lastLessonResult.date {
                nextLessonDate = NSDate(timeInterval: UserPreferences.lessonReminderInverval, sinceDate:lastLessonDate)
                let result = countLessonsRemainingForToday()
                if let e = result.error {
                    error = e
                } else {
                    if result.count <= 0 {
                        // This means that the lesson was already viewed today, and that the next lesson should be tomorrow
                        nextLessonDate =  lastLessonDate.theNextMorning()
                    }
                }
            }
        }
        
        return (nextLessonDate, error)
    }
    
    private func findLessonDate(first : Bool) -> (date: NSDate?, error : NSError?) {
        var lastLessonDate : NSDate? = nil
        var error : NSError? = nil

        let fetchRequest = NSFetchRequest(entityName: "LessonLog")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lessonDate", ascending: first)]
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "(baby == %@) AND numberOfWordsViewed >=\(WORDS_PER_WORDSET)",_baby)
        if let results = _managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [LessonLog] {
            lastLessonDate = results.count > 0 ? results.first?.lessonDate : nil
        }
        
        if error != nil {
            UsageAnalytics.trackError("Error trying to load word set from CoreData", error:error!);
        }
        
        return (lastLessonDate, error)
    }
    
    private func logLesson(wordSet : WordSet) {
        let useDay = self.dayOfProgram // NOTE: Must be done before inserting entity into context
        if let entityDescription = NSEntityDescription.entityForName("LessonLog", inManagedObjectContext:_managedObjectContext) {
            let log = LessonLog(entity: entityDescription, insertIntoManagedObjectContext: _managedObjectContext)
            log.baby = _baby
            log.numberOfWordsViewed = UInt16(_wordsViewedInLesson.count)
            log.wordSetNumber = wordSet.number
            log.words = ",".join((_wordsViewedInLesson.allObjects as [Word]).map { $0.text })
            log.lessonDate = _lessonStartTime!
            log.durationSeconds = -_lessonStartTime!.timeIntervalSinceNow
            log.totalNumberOfWordSets = UInt16(_baby.wordSets!.count)
            log.useDay = UInt16(useDay)
            
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
    
    private func calcCurrentUseDay() -> (day:Int, error:NSError?) {
        var error: NSError? = nil
        var day : Int = 0
        
        
        let fetchRequest = NSFetchRequest(entityName: "LessonLog")
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "useDay", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "(baby == %@)",_baby)
        let results = _managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [LessonLog]
        if error == nil {
            if let lastLesson = results.first {
                day = Int(lastLesson.lessonDate.isToday() ? lastLesson.useDay : lastLesson.useDay + 1)
            } else {
                day = 1 // Must be first day using since there are no records.
            }
        }
        
        return (day, error)
        
        
    }
    
    private func countLessonsRemainingForToday() -> (count:Int, error:NSError?) {
        var error: NSError? = nil
        var count : Int = 0
        let now = NSDate()
        
        let result = countLessonsGivenOnDate(now)
        if let err = result.error {
            error = err
        } else {
            count = self.numberOfLessonsPerDay - result.count
        }
        
        return (count > 0 ? count : 0 , error)
    }
    
    private func countLessonsGivenOnDate(date : NSDate) -> (count:Int, error:NSError?) {
        var error: NSError? = nil
        var count : Int = 0
        let fetchRequest = NSFetchRequest(entityName: "LessonLog")
        fetchRequest.predicate = NSPredicate(format: "(baby == %@) AND (lessonDate >= %@) AND (lessonDate <= %@) AND numberOfWordsViewed >=\(WORDS_PER_WORDSET)",_baby, date.startOfDay(), date.endOfDay())
        count = _managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        return (count, error)
    }
}

