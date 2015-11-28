//
//  User+CoreDataProperties.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var sid: String?
    @NSManaged var course: NSSet?
    @NSManaged var exam: NSSet?
    @NSManaged var score: NSSet?
    @NSManaged var semesterScore: NSSet?

}
