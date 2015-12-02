//
//  SemesterScore.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class SemesterScore: NSManagedObject {

    @NSManaged var year: String?
    @NSManaged var semester: String?
    @NSManaged var totalCredit: NSNumber?
    @NSManaged var averageGrade: NSNumber?
    @NSManaged var user: User?

}
