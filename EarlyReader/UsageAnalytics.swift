//
//  UsageAnalytics.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import CoreData

// TODO: EMail on

#if DEBUG
    private let _instance = UsageAnalytics()
#else
    private let _instance = UsageAnalyticsProd()
#endif


@objc(UsageAnalytics)
class UsageAnalytics {
    
    class var instance : UsageAnalytics {
        get {
            return _instance
        }
    }
    
    // TO BE OVERRIDDEN BY SUBCLASSES
    func trackEvent(eventName : String, eventProperties : Dictionary<String, AnyObject>?) {
        if let props = eventProperties {
            NSLog("[UsageAnalytics] - %@: %@", eventName, props)
        } else {
            NSLog("[UsageAnalytics] - %@", eventName)
        }
    }

    // TO BE OVERRIDDEN BY SUBCLASSES
    func identify() {
        var props : [String:AnyObject]? = nil
        if let baby = Baby.currentBaby {
            props = ["babyName" : baby.name, "babyDOB" : baby.birthDate]
        }
        trackEvent("identify", eventProperties: props)
    }
    
    
    func trackError(description: NSString, error: NSError) {
        var combinedAttributes = [String:AnyObject]()
        if let userDict = error.userInfo {
            for (key,value) in userDict {
                combinedAttributes.updateValue(value, forKey:key as String)
            }
        }
        combinedAttributes["error.id"] = error.code
        combinedAttributes["operation"] = description;
        combinedAttributes["timestamp"] = NSDate();
        combinedAttributes["error.domain"] =  error.domain
        trackEvent("Error", eventProperties: combinedAttributes)
    }

    func trackAppActivated() {
        var props : [String:String]? = nil
        if let b = Baby.currentBaby {
            var planner = LessonPlanner(baby: b)
            
            props = [
                "babyName" : b.name,
                "numberOfWordSets" : String(b.wordSets.count),
                "dayOfProgram" : String(planner.dayOfProgram),
                "reminderInterval" : String(format:"%.1f",UserPreferences.lessonReminderInverval)
            ]
        }
        trackEvent("appActivated", eventProperties: props)
    }

    
    // Lessons 
    func trackLessonStarted(planner: LessonPlanner) {
        var props : [String:String] = [
            "babyName" : planner.baby.name,
            "slideDisplayInterval" : String(format:"%.1f",UserPreferences.slideDisplayInverval)
        ]
        props["totalNumberOfLessonsForToday"] = String(planner.numberOfLessonsPerDay)
        props["lessonNumber"] = String(planner.numberOfLessonsTakenToday + 1)
        props["dayOfProgram"] = String(planner.dayOfProgram)
        props["wordsInLesson"] = ",".join((planner.wordPreviewForNextLesson()).map { $0.text })
        props["numberOfWordsInLesson"] = String(planner.wordPreviewForNextLesson().count)
        if let date = planner.lastLessonDate {
            props["timeSinceLastLesson"] = date.stringWithHumanizedTimeDifference()
            props["lastLessonTakenAt"] = date.toISO8601String()
        }
        trackEvent("lessonStarted", eventProperties: props)
    }

    func trackLessonAborted(planner : LessonPlanner) {
        trackEvent("lessonAborted", eventProperties: [
            "numberOfWordsSeen" : String(planner.numberOfWordsSeenDuringCurrentLesson),
            "duration" : String(format:"%.1f", planner.lastLessonDurationSeconds)
        ])
    }

    func trackLessonFinished(planner : LessonPlanner) {
        var props : [String:String] = [
            "babyName" : planner.baby.name,
            "numberOfWordsSeen" : String(planner.numberOfWordsSeenDuringCurrentLesson),
            "totalNumberOfLessonsForToday" : String(planner.numberOfLessonsPerDay),
            "lessonNumber" : String(planner.numberOfLessonsTakenToday + 1),
            "duration" : String(format:"%.1f", planner.lastLessonDurationSeconds)
        ]
        trackEvent("lessonFinished", eventProperties: props)
    }

    func trackWordsAdded(words : [String]) {
        trackEvent("wordsAdded", eventProperties: ["words" : ",".join((words)), "count" : String(words.count)])
    }
    
    func trackWordsDeleted(words : [Word]) {
        trackEvent("wordsDeleted", eventProperties: ["words" : ",".join((words).map { $0.text }), "count" : String(words.count)])
    }
    
    func trackNotificationCreated(notification : Notification ) {
        trackEvent("notificationCreated", eventProperties: ["key" : notification.key, "type" : notification.type.stringValue])
    }
    
    func trackNotificationClosed(notification : Notification ) {
        trackEvent("notificationDismissed", eventProperties: [
            "key" : notification.key,
            "type" : notification.type.stringValue,
            "timeUntilDismiss" : notification.deliveredOn.stringWithHumanizedTimeDifference(false)
            ])
    }
    
}

private class UsageAnalyticsProd: UsageAnalytics {
    
    
    
    
    // TO BE OVERRIDDEN BY SUBCLASSES
    override func trackEvent(eventName : String, eventProperties : Dictionary<String, AnyObject>?) {
        if let props = eventProperties {
            Heap.track(eventName, withProperties: eventProperties)
            Mixpanel.sharedInstance().track(eventName, properties: eventProperties)
        } else {
            Heap.track(eventName)
            Mixpanel.sharedInstance().track(eventName)
            // AppsFlyer
        }
    }
    
    // TO BE OVERRIDDEN BY SUBCLASSES
    override func identify() {
        var props : [String:AnyObject]? = nil
        if let baby = Baby.currentBaby {
            props = ["babyName" : baby.name, "babyDOB" : baby.birthDate]
        }
        
//            [AppsFlyerTracker sharedTracker].customerUserID = user.objectId;
//            [Heap identify:props];
//            [UXCam tagUsersName:user.objectId additionalData:user.email];
//            [UXCam addTag:user.isMale ? @"male" : @"female"];
//            [UXCam addTag:user.email ? @"anonymous" : @"signedup"];
//            //if (user.screenName) [UXCam tagScreenName:user.screenName]; // this causes the screenname to be used instead of the user id...not what we want.
//            [mixpanel identify:mixpanel.distinctId];
//            if (user.email) props[@"$email"] = user.email;
//            [mixpanel.people set:props];
        
        
    }
    

}

