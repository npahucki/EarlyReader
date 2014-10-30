//
//  UserPreferences.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

class UserPreferences {
    class var lessonReminderInverval : NSTimeInterval {
        set(lessonReminderInverval) {
            NSUserDefaults.standardUserDefaults().setDouble(lessonReminderInverval, forKey:"lessonReminderInverval");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().doubleForKey("lessonReminderInverval");
            return interval > 0 ? interval : 30.0
        }
    }
    
    class var numberOfWordSets : Int {
        set(numberOfWordSets) {
        NSUserDefaults.standardUserDefaults().setInteger(numberOfWordSets, forKey:"numberOfWordSets");
        }
        get {
            let numberSets = NSUserDefaults.standardUserDefaults().integerForKey("numberOfWordSets");
            return numberSets > 0 ? numberSets : 3
        }
    }
    
    class var slideDisplayInverval : NSTimeInterval {
        set(slideDisplayInverval) {
            NSUserDefaults.standardUserDefaults().setDouble(slideDisplayInverval, forKey:"slideDisplayInverval");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().doubleForKey("slideDisplayInverval");
            return interval > 0 ? interval : 1.5
        }
    }

    class var alwaysUseManualMode : Bool {
        set(alwaysUseManualMode) {
            NSUserDefaults.standardUserDefaults().setBool(alwaysUseManualMode, forKey:"alwaysUseManualMode");
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("alwaysUseManualMode");
        }
    }

    
    class var lastLessonTakenAt : NSDate? {
        set(lastLessonTakenAt) {
        NSUserDefaults.standardUserDefaults().setDouble(lastLessonTakenAt!.timeIntervalSince1970, forKey:"lastLessonTakenAt");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().doubleForKey("lastLessonTakenAt");
            return interval > 0 ? NSDate(timeIntervalSince1970: interval) : nil
        }
    }

    class var programStartedAt : NSDate? {
        set(programStartedAt) {
        NSUserDefaults.standardUserDefaults().setDouble(programStartedAt!.timeIntervalSince1970, forKey:"programStartedAt");
        }
        get {
            let interval = NSUserDefaults.standardUserDefaults().doubleForKey("programStartedAt");
            return interval > 0 ? NSDate(timeIntervalSince1970: interval) : nil
        }
    }


    
    
    
    
}

