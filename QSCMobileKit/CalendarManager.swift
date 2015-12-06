//
//  CalendarManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-03.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

/// The calendar manager which handles calendar queries. Singleton pattern is used in this class.
public class CalendarManager: NSObject {
    
    /**
     Override just to make init() private.
     */
    private override init() {
        super.init()
    }
    
    public static let sharedInstance = CalendarManager()
    
    private func entityForYear(date: NSDate) -> Year? {
        let fetchRequest = NSFetchRequest(entityName: "Year")
        fetchRequest.predicate = NSPredicate(format: "(start <= %@) AND (%@ < end)", date, date)
        return try! DataStore.managedObjectContext.executeFetchRequest(fetchRequest).first as? Year
    }
    
    private func entityForSemester(date: NSDate) -> Semester? {
        if let year = entityForYear(date) {
            for semester in year.semesters! {
                let semester = semester as! Semester
                if semester.start! <= date && date < semester.end! {
                    return semester
                }
            }
            return nil
        } else {
            return nil
        }
    }
    
    /**
     Return a string describing the academic year of the specified date.
     
     - parameter date: A date to be queried.
     
     - returns: A description like "2015-2016" or "" if failed.
     */
    public func yearForDate(date: NSDate = NSDate()) -> String {
        return entityForYear(date)?.name ?? ""
    }
    
    /**
     Return the semester of the specified date.
     
     - parameter date: A date to be queried.
     
     - returns: Corresponding `CalendarSemester` or `.Unknown` if failed.
     */
    public func semesterForDate(date: NSDate = NSDate()) -> CalendarSemester {
        if let semester = entityForSemester(date) {
            return CalendarSemester(rawValue: semester.name!) ?? .Unknown
        } else {
            return .Unknown
        }
    }
    
    /**
     Return a description if the specified date is a holiday.
     
     - parameter date: A date to be queried.
     
     - returns: The name of a holiday or nil.
     */
    public func holidayForDate(date: NSDate = NSDate()) -> String? {
        if let year = entityForYear(date) {
            for holiday in year.holidays! {
                let holiday = holiday as! Holiday
                if holiday.start! <= date && date < holiday.end! {
                    return holiday.name
                }
            }
            return nil
        } else {
            return nil
        }
    }
    
    /**
     Return a tuple if there is an adjustment on the specified date.
     
     - parameter date: A date to be queried.
     
     - returns: A tuple containing the name and the destination date of an adjustment or nil.
     */
    public func adjustmentForDate(date: NSDate = NSDate()) -> (name: String, toDate: NSDate)? {
        if let year = entityForYear(date) {
            for adjustment in year.adjustments! {
                let adjustment = adjustment as! Adjustment
                if adjustment.fromStart! <= date && date < adjustment.fromEnd! {
                    let toDate = adjustment.toStart!.dateByAddingTimeInterval(date.timeIntervalSinceDate(adjustment.fromStart!))
                    return (adjustment.name!, toDate)
                }
            }
            return nil
        } else {
            return nil
        }
    }
    
    /**
     Return the week ordinal of the specified date. We assume the first day of a week is Monday.
     
     - parameter date: A date to be queried.
     
     - returns: An integer representing the week ordinal or -1 if failed.
     */
    public func weekOrdinalForDate(date: NSDate = NSDate()) -> Int {
        if let semester = entityForSemester(date) {
            let weekTimeInterval = NSTimeInterval(604800)
            let dayTimeInterval = NSTimeInterval(86400)
            let calendar = NSCalendar.currentCalendar()
            
            var zeroMonday = semester.start!
            if (semester.startsWithWeekZero == false) {
                zeroMonday = zeroMonday.dateByAddingTimeInterval(-weekTimeInterval)
            }
            while calendar.component([.Weekday], fromDate: zeroMonday) != Weekday.Monday.rawValue {
                zeroMonday = zeroMonday.dateByAddingTimeInterval(-dayTimeInterval)
            }
            
            let components = calendar.components([.WeekdayOrdinal], fromDate: zeroMonday, toDate: date, options: [])
            return components.weekdayOrdinal
        } else {
            return -1
        }
    }
    
}
