//
//  Year+CoreDataProperties.swift
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

extension Year {

    @NSManaged var name: String?
    @NSManaged var start: NSDate?
    @NSManaged var end: NSDate?
    @NSManaged var calendar: Calendar?
    @NSManaged var semester: NSSet?
    @NSManaged var holiday: NSSet?
    @NSManaged var adjustment: NSSet?

}
