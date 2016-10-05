//
//  OverseaScore.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-10-05.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class OverseaScore: NSManagedObject {
    
    @NSManaged public var fourPoint: NSNumber?
    @NSManaged public var hundredPoint: NSNumber?
    @NSManaged var user: User?
    
}
