//
//  Year.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Year: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var start: NSDate?
    @NSManaged var end: NSDate?
    @NSManaged var semester: NSSet?
    @NSManaged var holiday: NSSet?
    @NSManaged var adjustment: NSSet?
    
    @NSManaged func addSemesterObject(value: Semester)
    @NSManaged func removeSemesterObject(value: Semester)
    @NSManaged func addHolidayObject(value: Holiday)
    @NSManaged func removeHolidayObject(value: Holiday)
    @NSManaged func addAdjustmentObject(value: Adjustment)
    @NSManaged func removeAdjustmentObject(value: Adjustment)

}
