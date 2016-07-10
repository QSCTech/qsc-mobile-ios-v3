//
//  Bus.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class Bus: NSManagedObject {

    @NSManaged public var name: String?
    @NSManaged public var serviceDays: String?
    @NSManaged public var note: String?
    @NSManaged public var busStops: NSSet?

}
