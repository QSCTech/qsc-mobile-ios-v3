//
//  CourseEvent.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

public class CourseEvent: NSManagedObject {

    @NSManaged public var identifier: String?
    @NSManaged public var tags: String?
    @NSManaged public var notes: String?
    @NSManaged public var hasReminder: NSNumber?
    @NSManaged public var teacher: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var ta: String?
    @NSManaged public var taEmail: String?
    @NSManaged public var taPhone: String?
    @NSManaged public var website: String?
    @NSManaged public var qqGroup: String?
    @NSManaged public var publicEmail: String?
    @NSManaged public var publicPassword: String?
    @NSManaged public var homeworks: NSSet?

}
