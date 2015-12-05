//
//  Common.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation

let AppKey = "aq86L/EUgOPxD7ZJzr3rK4zBRyo8oVzF"

let MobileAPIURL  = "https://m.zjuqsc.com/v3api/"
let NoticeURL     = "https://notice.zjuqsc.com"
let BoxURL        = "https://box.zjuqsc.com"
let TideURL       = "http://tide.zjuqsc.com/wp/"

let ZjuwlanLoginURL  = "https://net.zju.edu.cn/cgi-bin/srun_portal"
let ZjuwlanLogoutURL = "https://net.zju.edu.cn/rad_online.php"

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
 Abbreviations for semesters, used in JSON of calendar.
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
    
    var name: String {
        switch self {
        case .SummerMini:
            return "暑假短学期"
        case .Autumn:
            return "秋学期"
        case .Winter:
            return "冬学期"
        case .WinterMini:
            return "寒假短学期"
        case .Spring:
            return "春学期"
        case .Summer:
            return "夏学期"
        case .SummerVacation:
            return "暑假"
        default:
            return ""
        }
    }
    
}

extension String {
    
    /**
     Judge a string of course semester if includes the specified `CalendarSemester`. Note currently mini semesters have NOT been taken into account.
     
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
