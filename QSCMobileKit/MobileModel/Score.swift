//
//  Score.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class Score: NSManagedObject {

    @NSManaged public var credit: NSNumber?
    @NSManaged public var gradePoint: NSNumber?
    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var score: String?
    @NSManaged public var year: String?
    @NSManaged public var semester: String?
    @NSManaged public var makeup: String?
    @NSManaged var user: User?

}
