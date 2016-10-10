//
//  Homework.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

public class Homework: NSManagedObject {
    
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var addTime: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var isFinished: NSNumber?
    @NSManaged public var courseEvent: CourseEvent?
    
}
