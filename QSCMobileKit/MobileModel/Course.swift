//
//  Course.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class Course: NSManagedObject {

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var englishName: String?
    @NSManaged public var credit: NSNumber?
    @NSManaged public var category: String?
    @NSManaged public var faculty: String?
    @NSManaged public var teacher: String?
    @NSManaged public var semester: String?
    @NSManaged public var year: String?
    @NSManaged public var identifier: String?
    @NSManaged public var isDetermined: NSNumber?
    @NSManaged public var prerequisite: String?
    @NSManaged public var timePlaces: NSSet?
    @NSManaged var user: User?

}
