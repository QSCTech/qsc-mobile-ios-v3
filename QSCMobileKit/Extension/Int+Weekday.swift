//
//  Int+Weekday.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension Int {
    
    /**
     Create a string from the index of weekday, consistent with NSDateComponents. Note Monday is NOT 1 BUT 2, etc.
     */
    public var stringForWeekday: String {
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
    
    /**
     Return the Chinese character of 0..10.
     */
    public var chinese: String {
        switch self {
        case 0:
            return "〇"
        case 1:
            return "一"
        case 2:
            return "二"
        case 3:
            return "三"
        case 4:
            return "四"
        case 5:
            return "五"
        case 6:
            return "六"
        case 7:
            return "七"
        case 8:
            return "八"
        case 9:
            return "九"
        case 10:
            return "十"
        default:
            return ""
        }
    }
    
}

enum Weekday: Int {
    case Sunday = 1, Monday, Tuesday, Thursday, Friday, Saturday
}
