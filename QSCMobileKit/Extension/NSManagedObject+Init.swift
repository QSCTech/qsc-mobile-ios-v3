//
//  NSManagedObject+Init.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-01.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /**
     Covenience initializer for entity insertion.
     
     - parameter context: The managed object context to be inserted in.
     
     - returns: A entity of the specified class.
     */
    convenience init(in context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(String(self.dynamicType), inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
}
