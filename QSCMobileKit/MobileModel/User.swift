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
    @NSManaged var startSemester: String?
    @NSManaged var endSemester: String?
    @NSManaged var courses: NSSet?
    @NSManaged var exams: NSSet?
    @NSManaged var scores: NSSet?
    @NSManaged var semesterScores: NSSet?
    @NSManaged var statistics: Statistics?
    @NSManaged var overseaScore: OverseaScore?

}
