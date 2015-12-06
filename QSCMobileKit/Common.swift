//
//  Common.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

let AppKey = "aq86L/EUgOPxD7ZJzr3rK4zBRyo8oVzF"

let MobileAPIURL  = "https://m.zjuqsc.com/v3api/"
let NoticeURL     = "https://notice.zjuqsc.com"
let BoxURL        = "https://box.zjuqsc.com"
let TideURL       = "http://tide.zjuqsc.com/wp/"

let ZjuwlanLoginURL  = "https://net.zju.edu.cn/cgi-bin/srun_portal"
let ZjuwlanLogoutURL = "https://net.zju.edu.cn/rad_online.php"

public struct Event {
    public enum Type {
        case AllDay, PartialTime
    }
    public enum Category {
        case Course, Exam, Quiz, Custom
    }
    let type: Type
    let category: Category
    let tags: [String]
    let name: String
    let time: String
    let place: String
    let start: NSDate
    let end: NSDate
    let object: NSManagedObject
}

enum Weekday: Int {
    case Sunday = 1, Monday, Tuesday, Thursday, Friday, Saturday
}

extension Int {
    
    /**
     Create a string from the index of weekday, consistent with NSDateComponents. Note Monday is NOT 1 BUT 2, etc.
     */
    var stringForWeekday: String {
        switch self {
        case 1:
            return "星期日"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 7:
            return "星期六"
        default:
            return ""
        }
    }
    
}

extension String {
    
    var startTimeForPeriods: NSDateComponents {
        let time = NSDateComponents()
        if self.characters.count == 0 {
            return time
        }
        switch characters.first! {
        case "1":
            time.hour = 8
            time.minute = 0
        case "2":
            time.hour = 8
            time.minute = 50
        case "3":
            time.hour = 9
            time.minute = 50
        case "4":
            time.hour = 10
            time.minute = 40
        case "5":
            time.hour = 11
            time.minute = 30
        case "6":
            time.hour = 13
            time.minute = 15
        case "7":
            time.hour = 14
            time.minute = 5
        case "8":
            time.hour = 14
            time.minute = 55
        case "9":
            time.hour = 15
            time.minute = 55
        case "a":
            time.hour = 16
            time.minute = 45
        case "b":
            time.hour = 18
            time.minute = 30
        case "c":
            time.hour = 19
            time.minute = 20
        case "d":
            time.hour = 20
            time.minute = 10
        default:
            break
        }
        return time
    }
    
    var endTimeForPeriods: NSDateComponents {
        let time = NSDateComponents()
        if characters.count == 0 {
            return time
        }
        switch characters.last! {
        case "1":
            time.hour = 8
            time.minute = 45
        case "2":
            time.hour = 9
            time.minute = 35
        case "3":
            time.hour = 10
            time.minute = 35
        case "4":
            time.hour = 11
            time.minute = 25
        case "5":
            time.hour = 12
            time.minute = 15
        case "6":
            time.hour = 14
            time.minute = 0
        case "7":
            time.hour = 14
            time.minute = 50
        case "8":
            time.hour = 15
            time.minute = 40
        case "9":
            time.hour = 16
            time.minute = 40
        case "a":
            time.hour = 17
            time.minute = 30
        case "b":
            time.hour = 19
            time.minute = 15
        case "c":
            time.hour = 20
            time.minute = 5
        case "d":
            time.hour = 20
            time.minute = 55
        default:
            break
        }
        return time
    }
    
}

/**
 Chinese names of four seasons, used to identify the semester of courses.
 */
enum CourseSemester: String {
    case Spring = "春"
    case Summer = "夏"
    case Autumn = "秋"
    case Winter = "冬"
}

/**
 Abbreviations for semesters, used in JSON of calendar and scores.
 */
public enum CalendarSemester: String {
    
    case SummerMini     = "SM"
    case Autumn         = "Au"
    case Winter         = "Wi"
    case WinterMini     = "WM"
    case Spring         = "Sp"
    case Summer         = "Su"
    case SummerVacation = "ST"
    case Unknown        = "Unknown"
    
    /// Chinese name of semesters, used in JSON of courses and exams.
    var name: String {
        switch self {
        case .SummerMini:
            return "夏短"
        case .Autumn:
            return "秋"
        case .Winter:
            return "冬"
        case .WinterMini:
            return "冬短"
        case .Spring:
            return "春"
        case .Summer:
            return "夏"
        case .SummerVacation:
            return "暑"
        default:
            return ""
        }
    }
    
}

extension String {
    
    /**
     Judge if the specified Chinese characters includes the specified `CalendarSemester`. Note currently mini semesters have NOT been taken into account.
     
     - parameter semester: One of `CalendarSemester`.
     
     - returns: Whether it includes.
     */
    func includesSemester(semester: CalendarSemester) -> Bool {
        switch semester {
        case .Autumn:
            return containsString("秋")
        case .Winter:
            return containsString("冬")
        case .Spring:
            return containsString("春")
        case .Summer:
            return containsString("夏")
        default:
            return false
        }
    }
    
    /**
     Judge if a string of odd/even week matches the specified week ordinal.
     
     - parameter weekOrdinal: An integer representing the week ordinal.
     
     - returns: Whether it matches.
     */
    func matchesWeekOrdinal(weekOrdinal: Int) -> Bool {
        switch self {
        case "每周":
            return true
        case "单":
            return weekOrdinal % 2 == 1
        case "双":
            return weekOrdinal % 2 == 0
        default:
            return false
        }
    }
    
}

public func == (left: NSDate, right: NSDate) -> Bool {
    return left.compare(right) == .OrderedSame
}
public func < (left: NSDate, right: NSDate) -> Bool {
    return left.compare(right) == .OrderedAscending
}
extension NSDate: Comparable {}

public func += (inout left: String!, right: String) {
    left = (left ?? "") + right
}
