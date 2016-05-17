//
//  CourseEvent.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

class CourseEvent: NSManagedObject {

    @NSManaged var code: String?
    @NSManaged var tags: String?
    @NSManaged var comment: String?
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var website: String?
    @NSManaged var qqGroup: String?
    @NSManaged var publicEmail: String?
    @NSManaged var publicPassword: String?
    @NSManaged var homeworks: NSSet?

}
