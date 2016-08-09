//
//  NSDate+TodayTomorrow.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension NSDate {
    
    var today: NSDate {
        let calendar = NSCalendar.currentCalendar()
        return calendar.startOfDayForDate(self)
    }
    
    var tomorrow: NSDate {
        let dayTimeInterval = NSTimeInterval(86400)
        return today.dateByAddingTimeInterval(dayTimeInterval)
    }
    
}
