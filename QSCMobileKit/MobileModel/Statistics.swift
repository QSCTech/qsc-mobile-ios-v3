//
//  Statistics.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-01-22.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class Statistics: NSManagedObject {

    @NSManaged public var totalCredit: NSNumber?
    @NSManaged public var majorCredit: NSNumber?
    @NSManaged public var averageGrade: NSNumber?
    @NSManaged public var majorGrade: NSNumber?
    @NSManaged public var overseaGrade: NSNumber?
    @NSManaged var user: User?

}
