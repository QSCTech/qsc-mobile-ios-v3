//
//  NSNumber+Comparable.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

extension NSNumber: Comparable {}

public func == (left: NSNumber, right: NSNumber) -> Bool {
    return left.compare(right) == .orderedSame
}
public func < (left: NSNumber, right: NSNumber) -> Bool {
    return left.compare(right) == .orderedAscending
}
