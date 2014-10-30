//
//  NSDateExtensionsTests.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/29/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import XCTest

class NSDateExtensionsTests: XCTestCase {

    func testNextMorning() {
        let components = NSDateComponents()
        components.day = 11
        components.month = 11
        components.year = 2011
        components.hour = 11
        components.minute = 11
        components.second = 11
        
        
        let gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let startDate = gregorian?.dateFromComponents(components)
        NSLog("START DATE: %@", startDate!)

        let nextMorning = startDate?.theNextMorning()

        NSLog("NEXT MORNING: %@", nextMorning!)
        
        let nextMorningComponents = gregorian?.components((NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit), fromDate: nextMorning!)
        
        XCTAssertEqual(nextMorningComponents!.year, components.year, "Expected Same Year")
        XCTAssertEqual(nextMorningComponents!.month, components.month, "Expected Same Month")
        XCTAssertEqual(nextMorningComponents!.day, components.day + 1, "Expected Next Day")
        XCTAssertEqual(nextMorningComponents!.hour, 7, "Expected 7 am")
        XCTAssertEqual(nextMorningComponents!.minute, 0, "Expected 7 am")
        
        
    }
}
