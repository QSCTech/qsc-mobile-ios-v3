//
//  NSDate+QSCMobileKit.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension NSDate {
    
    public var today: NSDate {
        let calendar = NSCalendar.currentCalendar()
        return calendar.startOfDayForDate(self)
    }
    
    public var tomorrow: NSDate {
        let dayTimeInterval = NSTimeInterval(86400)
        return today.dateByAddingTimeInterval(dayTimeInterval)
    }
    
    private var datetimeFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy年M月d日    HH:mm"
        return formatter
    }
    
    public var stringOfDatetime: String {
        return datetimeFormatter.stringFromDate(self)
    }
    
    public var stringOfDate: String {
        return stringOfDatetime.componentsSeparatedByString("    ").first!
    }
    
    public var stringOfTime: String {
        return stringOfDatetime.componentsSeparatedByString("    ").last!
    }
    
}
