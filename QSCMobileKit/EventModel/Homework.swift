//
//  Homework.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

class Homework: NSManagedObject {

    @NSManaged var deadline: NSDate?
    @NSManaged var detail: String?
    @NSManaged var isFinished: NSNumber?
    @NSManaged var courseEvent: CourseEvent?

}
