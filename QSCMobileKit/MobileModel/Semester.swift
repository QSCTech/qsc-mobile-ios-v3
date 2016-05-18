//
//  Semester.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Semester: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var start: NSDate?
    @NSManaged var end: NSDate?
    @NSManaged var startsWithWeekZero: NSNumber?
    @NSManaged var year: Year?

}