//
//  TimePlace.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class TimePlace: NSManagedObject {

    @NSManaged var weekday: NSNumber?
    @NSManaged var week: String?
    @NSManaged var periods: String?
    @NSManaged var place: String?
    @NSManaged var time: String?
    @NSManaged var course: Course?

}
