//
//  Exam.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Exam: NSManagedObject {

    @NSManaged var credit: NSNumber?
    @NSManaged var identifier: String?
    @NSManaged var isRelearning: NSNumber?
    @NSManaged var name: String?
    @NSManaged var place: String?
    @NSManaged var seat: String?
    @NSManaged var semester: String?
    @NSManaged var time: String?
    @NSManaged var startTime: NSDate?
    @NSManaged var endTime: NSDate?
    @NSManaged var year: String?
    @NSManaged var user: User?

}
