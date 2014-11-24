//
//  LessonPlannerTests.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/31/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData
import XCTest
import LittleReader

class LessonPlannerTests: CoreDataUnitTestBase {

    var _planner : LessonPlanner! = nil
    
    override func setUp() {
        super.setUp()
        _planner = LessonPlanner(baby: baby!)
    }
    
    override func tearDown() {
        _planner = nil
        super.tearDown()
    }
    

    func testLastLessonDate() {
        let now = NSDate()
        createLessonLogEntry(now)
        createLessonLogEntry(now.dateYesterday())
        
        XCTAssertEqual(_planner.lastLessonDate!, now)
    }

    func testFistLessonDate() {
        let now = NSDate()
        createLessonLogEntry(now)
        createLessonLogEntry(now.dateTomorrow())
        
        XCTAssertEqual(_planner.firstLessonDate!, now)
    }

    
    func testNextLessonDateWhenNoPreviousLessons() {
        XCTAssertNil(_planner.lastLessonDate)
        // Next date should be right now
        XCTAssert(_planner?.nextLessonDate.timeIntervalSinceNow < 5,"Expected that the next lesson date be within a few seconds or now since there are no previous lessons taken")
    }

    func testNextLessonDateWhenLessonsForTodayRemain() {
        // Need some word sets 
        let now = NSDate()
        baby!.populateWordSets(2, numberOfWordsPerSet: 1)
        createLessonLogEntry(now)
        ctx.save(nil)
        
        
        UserPreferences.lessonReminderInverval = 30.0 // 30 secs
        let estimatedNext = now.dateByAddingTimeInterval(UserPreferences.lessonReminderInverval)
        // Next date should be right now
        let interval = _planner.nextLessonDate.timeIntervalSinceDate(now)
        XCTAssert(interval == UserPreferences.lessonReminderInverval,"Expected that the next lesson date would be in \(UserPreferences.lessonReminderInverval) seconds but was \(interval) seconds")
    }

    func testNextLessonDateWhenNoMoreLessonsForTodayRemain() {
        let now = NSDate()
        UserPreferences.numberOfTimesToRepeatEachWordSet = 1
        baby!.populateWordSets(1, numberOfWordsPerSet: 1)
        createLessonLogEntry(now)
        ctx.save(nil)
        
        
        UserPreferences.lessonReminderInverval = 30.0 // 30 secs
        // Next date should be right now
        XCTAssertEqual(_planner.nextLessonDate, now.theNextMorning(),"Expected that since all lessons for today are done, the next lesson would be due the next morning")
    }
    
    func testNumberOfLessonsPerDay() {
        UserPreferences.numberOfTimesToRepeatEachWordSet = 3
        baby!.populateWordSets(2, numberOfWordsPerSet: 1)
        XCTAssertEqual(_planner.numberOfLessonsPerDay,6) // 2 sets times 3 times a day
    }

    func testNumberOfLessonsRemainingToday() {
        let now = NSDate()
        UserPreferences.numberOfTimesToRepeatEachWordSet = 3
        baby!.populateWordSets(2, numberOfWordsPerSet: 1)
        ctx.save(nil)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,6) // 2 sets times 3 times a day
        
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,5)
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,4)
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,3)
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,2)
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,1)
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,0)
        createLessonLogEntry(now)
        XCTAssertEqual(_planner.numberOfLessonsRemainingToday,0)
    }

    
    func testNumberOfLessonsTakenToday() {
        let now = NSDate()
        
        XCTAssertEqual(_planner.numberOfLessonsTakenToday,0)
        createLessonLogEntry(now,wordSetNumber:0)
        XCTAssertEqual(_planner.numberOfLessonsTakenToday,1)
        createLessonLogEntry(now,wordSetNumber:1)
        XCTAssertEqual(_planner.numberOfLessonsTakenToday,2)
        createLessonLogEntry(now,wordSetNumber:2)
        XCTAssertEqual(_planner.numberOfLessonsTakenToday,3)
        createLessonLogEntry(now.dateYesterday() ,wordSetNumber:3)
        XCTAssertEqual(_planner.numberOfLessonsTakenToday,3)
        createLessonLogEntry(now.dateTomorrow() ,wordSetNumber:4)
        XCTAssertEqual(_planner.numberOfLessonsTakenToday,3)
    }
    
    func testDayOfProgramWithNoPreviousData() {
            XCTAssertEqual(_planner.dayOfProgram, 1)
    }

    func testDayOfProgramSeveralDaysIntoLesson() {
        XCTAssertEqual(_planner.dayOfProgram, 1)
        
        let firstLessonDate = NSDate()
        // Simulate several lesosns on the same day.
        createLessonLogEntry(firstLessonDate, wordSetNumber :  0, useDay : 1)
        createLessonLogEntry(firstLessonDate, wordSetNumber :  0, useDay : 1)
        createLessonLogEntry(firstLessonDate, wordSetNumber :  0, useDay : 1)
        XCTAssertEqual(_planner.dayOfProgram, 1)
        
        // Following day...
        createLessonLogEntry(firstLessonDate.dateByAddingDays(1), wordSetNumber :  0, useDay : 2)
        createLessonLogEntry(firstLessonDate.dateByAddingDays(2), wordSetNumber :  0, useDay : 3)
        createLessonLogEntry(firstLessonDate.dateByAddingDays(3), wordSetNumber :  0, useDay : 4)
        XCTAssertEqual(_planner.dayOfProgram, 5)
    }
    
    func testStartAndFinishLesson() {
        var wordsToImport = [String]()
        for var i = 0; i < 25; i++ {
            wordsToImport.append("word-" + String(i))
        }
        importWords(wordsToImport)

        let ws1 = createWordSet()
        let ws2 = createWordSet()
        let ws3 = createWordSet()

        let date1 = NSDate()
        
        ws1.fill()
        ws1.lastViewedOn = date1
        ws2.fill()
        ws2.lastViewedOn = date1.dateTomorrow()
        ws3.fill()
        ws3.lastViewedOn = date1.dateYesterday()

        // We excpect the words in ws3
        let words = _planner.startLesson()!
        XCTAssertEqual(words.count,WORDS_PER_WORDSET, "Expected an array of words with at least ")
        var retiredWord = words.first
        for w in words {
            XCTAssert(ws3.words.containsObject(w), "Expected \(w) to be present in wordset ws3, perhaps the wrong Set was returned?")
            
            // Mark each word as viewed
            _planner.markWordViewed(w)
            XCTAssert(w.timesViewed == 1, "Expected timesViewed would be incremented")
            XCTAssert(w.lastViewedOn?.timeIntervalSinceNow < 1, "Expected last viewed to be now")
        }

        retiredWord!.timesViewed = 16 // force retire
    
        
        XCTAssert(ws3.words.containsObject(retiredWord!) , "Expected \(retiredWord) to be present in wordset ws3 before")
        _planner.finishLesson()
        XCTAssert(!ws3.words.containsObject(retiredWord!) , "Expected '\(retiredWord!.text)' to be retired from wordset ws3")
        XCTAssertEqual(ws3.words.count,WORDS_PER_WORDSET , "Expected that wordset would be populated after retirement")
        XCTAssert(_planner.lastLessonDate?.timeIntervalSinceNow < 1,"Expected that last lesson date would be very close to now")
    }
    
    func testNumberOfAvailableWords() {
        importWords(["one","two"])
        XCTAssertEqual(_planner.numberOfAvailableWords, 2)
        importWords (["three"," four"])
        XCTAssertEqual(_planner.numberOfAvailableWords, 4)
    }
    

    private func createLessonLogEntry(date: NSDate, wordSetNumber: Int = 0, useDay : Int = 0) -> LessonLog {
        let entityDescription = NSEntityDescription.entityForName("LessonLog", inManagedObjectContext:ctx)
        XCTAssert(entityDescription != nil,"entityDescription came back nil!")
        XCTAssert(baby != nil,"baby should not be nil")
        
        let log = LessonLog(entity: entityDescription!, insertIntoManagedObjectContext: ctx)
        log.baby = self.baby!
        log.lessonDate = date
        log.useDay = UInt16(useDay)
        log.numberOfWordsViewed = 1
        log.words = "one;two;three;four;five"
        log.numberOfWordsViewed = 5
        log.wordSetNumber = UInt16(wordSetNumber)
        saveContext()
        return log
    }
    
    


}
