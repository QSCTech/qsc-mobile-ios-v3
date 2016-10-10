//
//  Exam.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class Exam: NSManagedObject {

    @NSManaged public var credit: NSNumber?
    @NSManaged public var identifier: String?
    @NSManaged public var isRelearning: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var place: String?
    @NSManaged public var seat: String?
    @NSManaged public var semester: String?
    @NSManaged public var time: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var year: String?
    @NSManaged var user: User?

}
