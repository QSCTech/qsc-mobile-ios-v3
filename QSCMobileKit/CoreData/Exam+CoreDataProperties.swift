//
//  Exam+CoreDataProperties.swift
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

extension Exam {

    @NSManaged var credit: NSNumber?
    @NSManaged var identifier: String?
    @NSManaged var isRelearning: NSNumber?
    @NSManaged var name: String?
    @NSManaged var place: String?
    @NSManaged var seat: String?
    @NSManaged var semester: String?
    @NSManaged var time: String?
    @NSManaged var timeStart: NSDate?
    @NSManaged var timeEnd: NSDate?
    @NSManaged var year: String?
    @NSManaged var user: User?

}
