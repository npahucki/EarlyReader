//
//  NotificationGenerator.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/2/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

/// Generates notifications based on time or or data events
@objc
public class NotificationGenerator {


    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataModelChange:", name: NSManagedObjectContextObjectsDidChangeNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleApplicationWakeup", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleBabyChange", name: NS_NOTIFICATION_CURRENT_BABY_CHANGED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func handleApplicationWakeup() {
        checkAndGenerateWordSetGuidanceNotification()
        checkAndGenerateLowWordCountNotification()
        checkAndGenerateTipIfNeeded()
    }

    func handleDataModelChange(note : NSNotification) {
        if note.object === Baby.currentBaby?.managedObjectContext {

            if let updatedObjects = note.userInfo![NSUpdatedObjectsKey] as? NSSet {
                for object in updatedObjects {
                    if let word = object as? Word {
                        checkAndGenerateLowWordCountNotification()
                    }
                }
            }
            
            if let deletedObjects = note.userInfo?[NSDeletedObjectsKey] as? NSSet {
                for object in deletedObjects {
                    if let word = object as? Word {
                        checkAndGenerateLowWordCountNotification()
                    } else if let wordSet = object as? WordSet {
                        checkAndGenerateWordSetGuidanceNotification()
                    }
                }
            }
            
            if let insertedObjects = note.userInfo?[NSInsertedObjectsKey] as? NSSet {
                for object in insertedObjects {
                    // The message may need to go away if there are enough words now!
                    if let word = object as? Word {
                        checkAndGenerateLowWordCountNotification()
                    }
                }
            }
            
        }
        
    }

    func handleBabyChange() {
        checkAndGenerateTipIfNeeded()
    }

    private func checkAndGenerateWordSetGuidanceNotification() {
        if let baby = Baby.currentBaby {
            let planner = LessonPlanner(baby: baby)
            let day = planner.dayOfProgram
            if baby.wordSets.count < planner.numberOfWordSetsForToday {
                let key = "increase_sets_for_program_day_" + String(planner.numberOfWordSetsForToday)
                if let notification = Notification.newUniqueNotification(.Guidance, key: key,
                    title: "notification_increase_sets_for_program_day_title", context:baby.managedObjectContext!) {
                        notification.message = NSString(format : NSLocalizedString("notification_increase_sets_for_program_day_msg", comment:""),planner.numberOfWordSetsForToday)
                        save(notification)
                }
            }
        }
    }

    private func checkAndGenerateLowWordCountNotification() {
        if let baby = Baby.currentBaby {
            let lowKey = "number_of_available_words_low"
            let outKey = "number_of_available_words_zero"

            let planner = LessonPlanner(baby: baby)
            if planner.numberOfAvailableWords < 1 {
                Notification.removeAllNotificaitonsWithKey(lowKey, context: baby.managedObjectContext!) // This message replaces the other
                if let notification = Notification.newNotificationIfNotOpen(.Alert, key: outKey, title: "alert_words_out_title", context: baby.managedObjectContext!) {
                    notification.message = "alert_words_out_msg"
                    save(notification)
                }
            } else if planner.numberOfAvailableWords < WORDS_PER_WORDSET {
                Notification.removeAllNotificaitonsWithKey(outKey, context: baby.managedObjectContext!)
                if let notification = Notification.newNotificationIfNotOpen(.Alert, key: lowKey, title: "alert_words_low_title", context: baby.managedObjectContext!) {
                    notification.message = "alert_words_low_msg"
                    save(notification)
                }
            } else {
                Notification.removeAllNotificaitonsWithKey(lowKey, context: baby.managedObjectContext!)
                Notification.removeAllNotificaitonsWithKey(outKey, context: baby.managedObjectContext!)
            }
        }
    }
    
    private func checkAndGenerateTipIfNeeded() {
        // Deliver no more than one tip per day, until they are all used.
        if let baby = Baby.currentBaby {
            let ctx = baby.managedObjectContext!
            let date = NSDate()
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Notification", inManagedObjectContext:ctx)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "deliveredOn", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "key LIKE 'tip-*' AND baby = %@",baby)
            fetchRequest.fetchLimit = 1
            var newTipKey : String = "tip-1"
            if let results = ctx.executeFetchRequest(fetchRequest, error: nil) as? [Notification] {
                if let last = results.last {
                    if last.deliveredOn.isToday() {
                        return // Already delivered for today
                    } else {
                        // Extract the key and add one to it.
                        if let numberPart = last.key.componentsSeparatedByString("-").last {
                            if let lastNumber = numberPart.toInt() {
                                newTipKey = "tip-\(lastNumber + 1)"
                                let titleKey = "\(newTipKey)_title"
                                if NSLocalizedString(titleKey,comment:"") == titleKey {
                                    // If the key was returned, it means there are no more tips.
                                    return
                                }
                            }
                        }
                    }
                }
            }
            
            if let notification = Notification.newUniqueNotification(.Tip, key: newTipKey,
                title: "\(newTipKey)_title", context:baby.managedObjectContext!) {
                    notification.message = "\(newTipKey)_msg"
                    save(notification)
            }
        }
    }
    
    
    private func save(notification : Notification) {
        var error : NSError?
        notification.managedObjectContext!.save(&error)
        if let e = error {
            UsageAnalytics.instance.trackError("Could not save notifications", error: e)
        } else {
            UsageAnalytics.instance.trackNotificationCreated(notification)
        }
    }
}