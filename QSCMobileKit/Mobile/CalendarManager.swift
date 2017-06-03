//
//  CalendarManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-03.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation

/// The calendar manager which handles calendar queries. Singleton pattern is used in this class.
public class CalendarManager: NSObject {
    
    /**
     Override just to make init() private.
     */
    private override init() {
        super.init()
    }
    
    public static let sharedInstance = CalendarManager()
    
    private func entityForSemester(_ date: Date) -> Semester? {
        if let year = DataStore.entityForYear(date) {
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
    public func yearForDate(_ date: Date) -> String {
        return DataStore.entityForYear(date)?.name ?? ""
    }
    
    /**
     Return the semester of the specified date.
     
     - parameter date: A date to be queried.
     
     - returns: Corresponding `CalendarSemester` or `.Unknown` if failed.
     */
    public func semesterForDate(_ date: Date) -> CalendarSemester {
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
    public func holidayForDate(_ date: Date) -> String? {
        if let year = DataStore.entityForYear(date) {
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
     Return a tuple if there is an adjustment onto the specified date.
     
     - parameter date: A date to be queried.
     
     - returns: A tuple containing the name and the source date of an adjustment or nil.
     */
    public func adjustmentForDate(_ date: Date) -> (name: String, fromDate: Date)? {
        if let year = DataStore.entityForYear(date) {
            for adjustment in year.adjustments! {
                let adjustment = adjustment as! Adjustment
                if adjustment.toStart! <= date && date < adjustment.toEnd! {
                    let fromDate = adjustment.fromStart!.addingTimeInterval(date.timeIntervalSince(adjustment.toStart!))
                    return (adjustment.name!, fromDate)
                }
            }
            return nil
        } else {
            return nil
        }
    }
    
    /**
     Return an array if there is a special arrangement of the crouse on the date.
     
     - parameter course: A course to be queried.
     - parameter date: A date to be queried.
     
     - returns: An array of special arrangements of the course on the date or nil.
     */
    public func specialsForCourse(course: Course, date: Date) -> [Special]? {
        var specials: [Special] = []
        if let year = DataStore.entityForYear(date) {
            for special in year.specials! {
                let special = special as! Special
                if special.code == course.code {
                    specials.append(special)
                }
            }
        }
        if specials.isEmpty {
            return nil
        } else {
            return specials
        }
    }
    
    /**
     Return the week ordinal of the specified date. We assume the first day of a week is Monday.
     
     - parameter date: A date to be queried.
     
     - returns: An integer representing the week ordinal or -1 if failed.
     */
    public func weekOrdinalForDate(_ date: Date) -> Int {
        if let semester = entityForSemester(date) {
            let weekTimeInterval = TimeInterval(604800)
            let dayTimeInterval = TimeInterval(86400)
            
            var zeroMonday = semester.start!
            if semester.startsWithWeekZero == false {
                zeroMonday = zeroMonday.addingTimeInterval(-weekTimeInterval)
            }
            while Calendar.current.component(.weekday, from: zeroMonday) != Weekday.monday.rawValue {
                zeroMonday = zeroMonday.addingTimeInterval(-dayTimeInterval)
            }
            
            let components = Calendar.current.dateComponents([.weekdayOrdinal], from: zeroMonday, to: date)
            return components.weekdayOrdinal!
        } else {
            return -1
        }
    }
    
}
