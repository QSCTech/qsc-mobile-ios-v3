//
//  File.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/20.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

public class File: NSManagedObject {
    
    @NSManaged public var code: String
    @NSManaged public var name: String
    @NSManaged public var directory: String
    @NSManaged public var password: String
    @NSManaged public var secid: String
    @NSManaged public var dueDate: Date
    @NSManaged public var operationDate: Date
    @NSManaged public var state: String
    @NSManaged public var progress: NSNumber
   
}
