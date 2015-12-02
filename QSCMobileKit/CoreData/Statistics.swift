//
//  Statistics.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-02.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class Statistics: NSManagedObject {

    @NSManaged var totalCredit: NSNumber?
    @NSManaged var averageGrade: NSNumber?
    @NSManaged var majorCredit: NSNumber?
    @NSManaged var majorGrade: NSNumber?
    @NSManaged var user: User?
    
}
