//
//  Course.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Course: NSManagedObject {

    @NSManaged var code: String?
    @NSManaged var name: String?
    @NSManaged var englishName: String?
    @NSManaged var credit: NSNumber?
    @NSManaged var category: String?
    @NSManaged var faculty: String?
    @NSManaged var teacher: String?
    @NSManaged var semester: String?
    @NSManaged var year: String?
    @NSManaged var identifier: String?
    @NSManaged var determined: NSNumber?
    @NSManaged var prerequisite: String?
    @NSManaged var user: User?
    @NSManaged var timePlaces: NSSet?
}
