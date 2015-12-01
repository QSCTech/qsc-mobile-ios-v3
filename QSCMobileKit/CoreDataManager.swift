//
//  CoreDataManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-30.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

/// The CoreData manager, in which Singleton pattern is used. Make sure current account is not nil, otherwise initialization will crash.
class CoreDataManager: NSObject {
    
    private override init() {
        let modelURL = NSBundle(identifier: "com.zjuqsc.QSCMobileKit")!.URLForResource("Model", withExtension: "momd")!
        let storeURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.zjuqsc.QSCMobileV3")!.URLByAppendingPathComponent("QSCMobileV3.sqlite")
        
        let mom = NSManagedObjectModel(contentsOfURL: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let accountManager = AccountManager.sharedInstance
        currentAccount = accountManager.currentAccountForJwbinfosys!
        
        super.init()
    }
    
    static let sharedInstance = CoreDataManager()
    
    var managedObjectContext: NSManagedObjectContext
    var currentAccount: String
    
}
