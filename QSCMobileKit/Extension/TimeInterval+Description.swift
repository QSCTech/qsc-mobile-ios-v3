//
//  TimeInterval+Description.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-12-06.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    public var timeDescription: String {
        let oneMoreMinute = Int(self) + 60
        return String(format: "%02d:%02d", oneMoreMinute / 3600, oneMoreMinute / 60 % 60)
    }
    
}
