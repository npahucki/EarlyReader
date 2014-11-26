//
//  DateExtensions.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

private let componentFlags = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.WeekCalendarUnit |  NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit | NSCalendarUnit.WeekdayOrdinalCalendarUnit);
private let iso8601FormatString = "yyyy-MM-dd'T'HHmmssZ"

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
    
    class func dateFromISO8601String(dateString : NSString) -> NSDate? {
        var dateString2 = dateString
        if dateString2.hasSuffix("Z") {
            dateString2 = dateString2.substringToIndex(dateString2.length-1).stringByAppendingString("-0000")
        }
        dateString2 = dateString2.stringByReplacingOccurrencesOfString(":", withString:"")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = iso8601FormatString
        return dateFormatter.dateFromString(dateString2)
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
    
    /// Returns the day at midnight (the start of the date)
    func startOfDay() -> NSDate {
        let gregorian = NSCalendar(calendarIdentifier : NSGregorianCalendar)
        let components = gregorian!.components((NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit), fromDate: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return gregorian?.dateFromComponents(components) ?? self
    }

    /// Returns the day at 11:59:59 (the end of the date)
    func endOfDay() -> NSDate {
        let gregorian = NSCalendar(calendarIdentifier : NSGregorianCalendar)
        let components = gregorian!.components((NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit), fromDate: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
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
    
    func isPast() -> Bool {
        return self.timeIntervalSinceNow < 0
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
    
    func toISO8601String() -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = iso8601FormatString
        return dateFormatter.stringFromDate(self)
    }
    
}
