//
//  SemesterScore.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class SemesterScore: NSManagedObject {

    @NSManaged public var year: String?
    @NSManaged public var semester: String?
    @NSManaged public var totalCredit: NSNumber?
    @NSManaged public var averageGrade: NSNumber?
    @NSManaged var user: User?

}
