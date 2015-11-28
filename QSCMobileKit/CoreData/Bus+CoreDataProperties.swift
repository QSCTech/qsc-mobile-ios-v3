//
//  Bus+CoreDataProperties.swift
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

extension Bus {

    @NSManaged var name: String?
    @NSManaged var serviceDays: String?
    @NSManaged var note: String?
    @NSManaged var busStop: NSSet?

}
