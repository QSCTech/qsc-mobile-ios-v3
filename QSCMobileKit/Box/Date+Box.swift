//
//  Date+Box.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import Foundation

public extension Date {
    
    public static let oneHourInSeconds: TimeInterval = 1 * 60 * 60
    public static let oneDayInSeconds: TimeInterval = 24 * Date.oneHourInSeconds
    public static let fiveDaysInSeconds: TimeInterval = 5 * Date.oneDayInSeconds
    public static let tenDaysInSeconds: TimeInterval = 10 * Date.oneDayInSeconds
    public static let thirtyDaysInSeconds: TimeInterval = 30 * Date.oneDayInSeconds
    public static let expirationsInSeconds: [TimeInterval] = [oneHourInSeconds, oneDayInSeconds, fiveDaysInSeconds, tenDaysInSeconds, thirtyDaysInSeconds]
    
    public static func dateToShortString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: date)
    }
    
    public static func dateToShortStringWithoutDots(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    public static func dateToLongString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    public static func completeStringToDate(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter.date(from: string)!
    }
    
}
