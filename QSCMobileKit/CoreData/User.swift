//
//  User.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

    @NSManaged var sid: String?
    @NSManaged var course: NSSet?
    @NSManaged var exam: NSSet?
    @NSManaged var score: NSSet?
    @NSManaged var semesterScore: NSSet?

}
