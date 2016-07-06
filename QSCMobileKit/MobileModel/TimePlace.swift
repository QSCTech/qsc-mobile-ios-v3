//
//  TimePlace.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class TimePlace: NSManagedObject {

    @NSManaged public var weekday: NSNumber?
    @NSManaged public var week: String?
    @NSManaged public var periods: String?
    @NSManaged public var place: String?
    @NSManaged public var time: String?
    @NSManaged public var course: Course?

}
