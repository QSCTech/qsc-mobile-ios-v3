//
//  Score.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Score: NSManagedObject {

    @NSManaged var credit: NSNumber?
    @NSManaged var gradePoint: NSNumber?
    @NSManaged var identifier: String?
    @NSManaged var name: String?
    @NSManaged var score: String?
    @NSManaged var year: String?
    @NSManaged var semester: String?
    @NSManaged var makeup: String?
    @NSManaged var user: User?

}
