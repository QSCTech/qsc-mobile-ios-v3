//
//  Bus.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Bus: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var serviceDays: String?
    @NSManaged var note: String?
    @NSManaged var busStops: NSSet?

}
