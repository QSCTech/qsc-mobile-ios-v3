//
//  BusStop.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class BusStop: NSManagedObject {

    @NSManaged public var campus: String?
    @NSManaged public var time: String?
    @NSManaged public var location: String?
    @NSManaged public var index: NSNumber?
    @NSManaged public var bus: Bus?

}
