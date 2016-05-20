//
//  CustomEvent.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

class CustomEvent: NSManagedObject {

    @NSManaged var duration: NSNumber?
    @NSManaged var category: NSNumber?
    @NSManaged var name: String?
    @NSManaged var tags: String?
    @NSManaged var place: String?
    @NSManaged var start: NSDate?
    @NSManaged var end: NSDate?
    @NSManaged var time: String?
    @NSManaged var repeatType: NSNumber?
    @NSManaged var repeatEnd: NSDate?
    @NSManaged var hasReminder: NSNumber?
    @NSManaged var sponsor: String?
    @NSManaged var notes: String?

}
