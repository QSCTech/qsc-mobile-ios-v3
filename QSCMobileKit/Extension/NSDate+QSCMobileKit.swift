//
//  NSDate+QSCMobileKit.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension Date {
    
    public var today: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return calendar.startOfDay(for: self)
    }
    
    public var tomorrow: Date {
        let dayTimeInterval = TimeInterval(86400)
        return today.addingTimeInterval(dayTimeInterval)
    }
    
    private var datetimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy年M月d日    HH:mm"
        return formatter
    }
    
    public var stringOfDatetime: String {
        return datetimeFormatter.string(from: self)
    }
    
    public var stringOfDate: String {
        return stringOfDatetime.components(separatedBy: "    ").first!
    }
    
    public var stringOfTime: String {
        return stringOfDatetime.components(separatedBy: "    ").last!
    }
    
}
