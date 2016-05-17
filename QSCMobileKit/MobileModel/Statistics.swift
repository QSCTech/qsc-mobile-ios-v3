//
//  Statistics.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-01-22.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Statistics: NSManagedObject {

    @NSManaged var totalCredit: NSNumber?
    @NSManaged var majorCredit: NSNumber?
    @NSManaged var averageGrade: NSNumber?
    @NSManaged var majorGrade: NSNumber?
    @NSManaged var overseaGrade: NSNumber?
    @NSManaged var user: User?

}
