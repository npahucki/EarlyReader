//
//  DateExtensions.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

private let componentFlags = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.WeekCalendarUnit |  NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit | NSCalendarUnit.WeekdayOrdinalCalendarUnit);


extension NSDate {
    
    class func now() -> NSDate {
        return NSDate()
    }

    
    class func dateWithDaysFromNow(days : Int) -> NSDate {
        return NSDate().dateByAddingDays(days)
    }
    
    class func dateWithDaysBeforeNow(days : Int) ->NSDate  {
        return NSDate().dateByAddingDays(-days)
    }
    
    func dateByAddingDays(days: Int) -> NSDate {
        let gregorian = NSCalendar(calendarIdentifier : NSGregorianCalendar)
        let dateComponents = NSDateComponents()
        dateComponents.day = days
        return gregorian?.dateByAddingComponents(dateComponents, toDate:self, options:NSCalendarOptions.allZeros) ?? self
    }
    
    /// Calculate the next morning at 7 am.
    func theNextMorning() -> NSDate {
        let gregorian = NSCalendar(calendarIdentifier : NSGregorianCalendar)
        let components = gregorian!.components((NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit), fromDate: self)
        components.day++
        components.hour = 7
        components.minute = 0
        components.second = 0
        return gregorian?.dateFromComponents(components) ?? self
    }
    
    
    func isEqualToDateIgnoringTime(aDate: NSDate) -> Bool {
        let cal = NSCalendar(calendarIdentifier : NSGregorianCalendar)
        let components1 = cal?.components(componentFlags, fromDate: self)
        let components2 = cal?.components(componentFlags, fromDate:aDate)
        return
            (components1?.year == components2?.year) &&
            (components1?.month == components2?.month) &&
            (components1?.day == components2?.day)
    }
    
    func isToday() ->Bool {
        return isEqualToDateIgnoringTime(NSDate())
    }
    
    func dateTomorrow() -> NSDate {
        return NSDate.dateWithDaysFromNow(1)
    }
    
    func dateYesterday() -> NSDate {
        return NSDate.dateWithDaysBeforeNow(1)
    }
    
    func isTomorrow() -> Bool {
        return self.isEqualToDateIgnoringTime(NSDate.now().dateTomorrow())
    }
    
    func isYesterday() -> Bool {
        return self.isEqualToDateIgnoringTime(NSDate.now().dateYesterday())
    }
    
}
