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

/**
 Index of weekdays, consistent with NSDateComponents. Note Monday is NOT 1 BUT 2, etc.
 */
enum Weekday: Int16 {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
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
