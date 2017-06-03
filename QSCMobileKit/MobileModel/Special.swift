//
//  Special.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017-06-03.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


public class Special: NSManagedObject {

    @NSManaged var code: String?
    @NSManaged var weekly: String?
    @NSManaged var date: Date?
    @NSManaged var year: Year?

}
