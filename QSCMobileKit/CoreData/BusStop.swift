//
//  BusStop.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class BusStop: NSManagedObject {

    @NSManaged var campus: String?
    @NSManaged var time: String?
    @NSManaged var location: String?
    @NSManaged var index: NSNumber?
    @NSManaged var bus: Bus?

}
