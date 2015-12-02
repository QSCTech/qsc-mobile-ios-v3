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

extension NSNumber {
    
    /**
     Create a string from the index of weekday, consistent with NSDateComponents. Note Monday is NOT 1 BUT 2, etc.
     */
    var stringForWeekday: String {
        switch integerValue {
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
enum CalendarSemester: String {
    case SummerMini     = "SM"
    case Autumn         = "Au"
    case Winter         = "Wi"
    case WinterMini     = "WM"
    case Spring         = "Sp"
    case Summer         = "Su"
    case SummerVacation = "ST"
}
