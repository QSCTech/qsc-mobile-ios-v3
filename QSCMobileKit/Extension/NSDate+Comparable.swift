//
//  NSDate+Comparable.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension NSDate: Comparable {}

public func == (left: NSDate, right: NSDate) -> Bool {
    return left.compare(right) == .OrderedSame
}
public func < (left: NSDate, right: NSDate) -> Bool {
    return left.compare(right) == .OrderedAscending
}
