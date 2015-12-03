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
    @NSManaged var totalCredit: NSNumber?
    @NSManaged var averageGrade: NSNumber?
    @NSManaged var majorCredit: NSNumber?
    @NSManaged var majorGrade: NSNumber?
    @NSManaged var courses: NSSet?
    @NSManaged var exams: NSSet?
    @NSManaged var scores: NSSet?
    @NSManaged var semesterScores: NSSet?

}
