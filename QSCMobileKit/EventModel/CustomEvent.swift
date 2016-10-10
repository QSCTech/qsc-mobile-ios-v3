//
//  CustomEvent.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

public class CustomEvent: NSManagedObject {

    @NSManaged public var duration: NSNumber?
    @NSManaged public var category: NSNumber?
    @NSManaged public var tags: String?
    @NSManaged public var name: String?
    @NSManaged public var place: String?
    @NSManaged public var start: Date?
    @NSManaged public var end: Date?
    @NSManaged public var repeatType: String?
    @NSManaged public var repeatEnd: Date?
    @NSManaged public var notification: NSNumber?
    @NSManaged public var sponsor: String?
    @NSManaged public var notes: String?

}
