//
//  Year.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Year: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var start: Date?
    @NSManaged var end: Date?
    @NSManaged var semesters: NSSet?
    @NSManaged var holidays: NSSet?
    @NSManaged var adjustments: NSSet?
}
