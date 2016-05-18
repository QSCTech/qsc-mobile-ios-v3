//
//  Adjustment.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Adjustment: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var fromStart: NSDate?
    @NSManaged var fromEnd: NSDate?
    @NSManaged var toStart: NSDate?
    @NSManaged var toEnd: NSDate?
    @NSManaged var year: Year?

}