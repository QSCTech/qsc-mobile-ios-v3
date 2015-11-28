//
//  SemesterScore+CoreDataProperties.swift
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

extension SemesterScore {

    @NSManaged var year: String?
    @NSManaged var semester: String?
    @NSManaged var totalCredit: NSNumber?
    @NSManaged var averageGrade: NSNumber?
    @NSManaged var majorCredit: NSNumber?
    @NSManaged var majorGrade: NSNumber?
    @NSManaged var user: User?

}
