//
//  EventManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

public class EventManager: NSObject {
    
    /**
     Override just to make init() private.
     */
    private override init() {
        super.init()
    }
    
    public static let sharedInstance = EventManager()
    
    private let managedObjectContext: NSManagedObjectContext = {
        let modelURL = NSBundle(identifier: QSCMobileKitIdentifier)!.URLForResource("Event", withExtension: "momd")!
        let storeURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(AppGroupIdentifier)!.URLByAppendingPathComponent("Event.sqlite")
        
        let mom = NSManagedObjectModel(contentsOfURL: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        return moc
    }()
    
    // MARK: - Retrieval
    
    public func courseEventForCode(code: String) -> CourseEvent? {
        let request = NSFetchRequest(entityName: "CourseEvent")
        request.predicate = NSPredicate(format: "code CONTAINS %@", code)
        return try! managedObjectContext.executeFetchRequest(request).first as? CourseEvent
    }
    
    // TODO: Handle repetition
    func customEventsForDate(date: NSDate) -> [CustomEvent] {
        let request = NSFetchRequest(entityName: "CustomEvent")
        request.predicate = NSPredicate(format: "(start < %@) AND (end >= %@)", date.tomorrow, date.today)
        let events = try! managedObjectContext.executeFetchRequest(request) as! [CustomEvent]
        
        return events.sort { $0.start <= $1.start }
    }
    
    // MARK: - Creation
    
    /**
     Create an event entity for the course with the given code. If that entity exists, this method will do nothing.
     
     - parameter code: Code of the course.
     */
    func createCourseEvent(code: String) {
        if courseEventForCode(code) == nil {
            let courseEvent = CourseEvent(context: managedObjectContext)
            courseEvent.code = code
            try! managedObjectContext.save()
        }
    }
    
    /**
     Create a custom event and accept a handler to modify it before saving.
     
     - parameter handler: A handler which takes an custom event as argument.
     */
    public func createCustomEvent(handler: (CustomEvent) -> Void) {
        let customEvent = CustomEvent(context: managedObjectContext)
        handler(customEvent)
        try! managedObjectContext.save()
    }
    
}
