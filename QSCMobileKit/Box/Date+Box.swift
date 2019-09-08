//
//  Date+Box.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import Foundation

public extension Date {
    
    static let oneHourInSeconds: TimeInterval = 1 * 60 * 60
    static let oneDayInSeconds: TimeInterval = 24 * Date.oneHourInSeconds
    static let fiveDaysInSeconds: TimeInterval = 5 * Date.oneDayInSeconds
    static let tenDaysInSeconds: TimeInterval = 10 * Date.oneDayInSeconds
    static let thirtyDaysInSeconds: TimeInterval = 30 * Date.oneDayInSeconds
    static let expirationsInSeconds: [TimeInterval] = [oneHourInSeconds, oneDayInSeconds, fiveDaysInSeconds, tenDaysInSeconds, thirtyDaysInSeconds]
    
    static func dateToShortString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: date)
    }
    
    static func dateToShortStringWithoutDots(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    static func dateToLongString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    static func completeStringToDate(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter.date(from: string)!
    }
    
}
