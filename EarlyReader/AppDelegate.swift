//
//  AppDelegate.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 8/16/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        // registering for sending user various kinds of notifications
        if application.respondsToSelector("registerUserNotificationSettings:") {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        } // Else...ios7 doesn't need permission to use local notifications.
        
        // Inject this so it can be injected into the other view controllers.
        var rootViewController = self.window!.rootViewController as MainViewController
        _mainManagedObjectContext = self.managedObjectContext
        rootViewController.managedContext = self.managedObjectContext
        
        // UIAppearance Settings
        let defaultFont = UIFont(name: "OpenSans", size: 17.0)
        UIButton.appearance().titleLabel?.font = defaultFont
        UITextField.appearance().borderStyle = UITextBorderStyle.None
        UITextField.appearance().backgroundColor = UIColor.whiteColor()
        
        UsageAnalytics.instance.identify()
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        processNotifiations()
        UsageAnalytics.instance.trackAppActivated()
    }
    
    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("EarlyReader", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("EarlyReader.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "EarlyReader", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            UsageAnalytics.instance.trackError("Failed to create the persistentStoreCoordinator", error: error!)
            UIAlertView(title: "Bad News", message: "The database schema has changed in a recent update, this means that you'll have to delete the app and install it again. The app will exit now.", delegate: nil, cancelButtonTitle : "Sigh, Ok").showAlertWithButtonBlock(){ $0; abort() }
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                UsageAnalytics.instance.trackError("Failed to create the persistentStoreCoordinator", error: error!)
                UIAlertView(title: "Bad News", message: "The database schema has changed in a recent update, this means that you'll have to delete the app and install it again. The app will exit now.", delegate: nil, cancelButtonTitle : "Sigh, Ok").showAlertWithButtonBlock(){ $0; abort() }
            }
        }
    }
    
    private func processNotifiations() {
        if let baby = Baby.currentBaby {
            if let ctx = managedObjectContext {
                // TODO: Tips
                let planner = LessonPlanner(baby: baby)
                let day = planner.dayOfProgram
                
                // Checking that the number of word sets is correct
                if planner.numberOfWordSetsForToday < baby.wordSets.count {
                    let key = "increase_sets_for_program_day_" + String(day)
                    if let notification = Notification.newUniqueNotification(.Guidance, key: key, title: "notification_increase_sets_for_program_day_title", context: ctx) {
                        notification.message = NSString(format : NSLocalizedString("notification_increase_sets_for_program_day_msg", comment:""),planner.numberOfWordSetsForToday)
                        UsageAnalytics.instance.trackNotificationCreated(notification)
                        saveContext()
                    }
                }
                
                // TODO: Move to a listener for changes in the context.
                // Checking that we have enough words
                if planner.numberOfAvailableWords < 25 {
                    let key = "number_of_words_low_25"
                    if let notification = Notification.newUniqueNotification(.Alert, key: key, title: "alert_words_low_25_title", context: ctx) {
                        notification.message = "alert_words_low_25_msg"
                        UsageAnalytics.instance.trackNotificationCreated(notification)
                        saveContext()
                    }
                }
                
                if planner.numberOfAvailableWords < 1 {
                    let key = "number_of_words_out_\(NSDate().startOfDay())"  // Make the alert come back everyday
                    if let notification = Notification.newUniqueNotification(.Alert, key: key, title: "alert_words_out_title", context: ctx) {
                        notification.message = "alert_words_out_msg"
                        UsageAnalytics.instance.trackNotificationCreated(notification)
                        saveContext()
                    }
                }

            }
        }
    }
}

