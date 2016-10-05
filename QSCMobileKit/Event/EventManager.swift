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
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        return moc
    }()
    
    // MARK: - Retrieval
    
    /**
     Return the corresponding event for courses with the identifier.
     
     - parameter identifier: Whose first 22 characters are used as the identifier.
     
     - returns: The object of `CourseEvent`.
     */
    public func courseEventForIdentifier(identifier: String) -> CourseEvent? {
        let identifier = identifier.substringToIndex(identifier.startIndex.advancedBy(22))
        let request = NSFetchRequest(entityName: "CourseEvent")
        request.predicate = NSPredicate(format: "identifier CONTAINS %@", identifier)
        return try! managedObjectContext.executeFetchRequest(request).first as? CourseEvent
    }
    
    // TODO: Support notifications
    public func customEventsForDate(date: NSDate) -> [Event] {
        var actualDates = [CustomEvent: (start: NSDate, end: NSDate)]()
        
        let request = NSFetchRequest(entityName: "CustomEvent")
        request.predicate = NSPredicate(format: "(start < %@) AND (end >= %@)", date.tomorrow, date.today)
        var events = try! managedObjectContext.executeFetchRequest(request) as! [CustomEvent]
        for event in events {
            actualDates[event] = (event.start!, event.end!)
        }
        
        request.predicate = NSPredicate(format: "(end < %@) AND (repeatType != \"永不\") AND (repeatEnd >= %@)", date.today, date.today)
        let repeatable = try! managedObjectContext.executeFetchRequest(request) as! [CustomEvent]
        let calendar = NSCalendar.currentCalendar()
        for event in repeatable {
            let startComponents: NSDateComponents
            switch event.repeatType! {
            case "每周", "每两周":
                startComponents = calendar.components([.Weekday, .Hour, .Minute, .Second], fromDate: event.start!)
            case "每月":
                startComponents = calendar.components([.Day, .Hour, .Minute, .Second], fromDate: event.start!)
            default:
                startComponents = calendar.components([.Hour, .Minute, .Second], fromDate: event.start!)
            }
            let timeInterval = event.end!.timeIntervalSinceDate(event.start!)
            var flag = false
            calendar.enumerateDatesStartingAfterDate(event.start!, matchingComponents: startComponents, options: .MatchStrictly) { start, _, stop in
                if start! >= date.tomorrow {
                    stop.memory = true
                    return
                }
                flag = !flag
                if event.repeatType == "每两周" && flag {
                    return
                }
                let end = start?.dateByAddingTimeInterval(timeInterval)
                if start! < date.tomorrow && end! >= date.today {
                    actualDates[event] = (start!, end!)
                    events.append(event)
                }
            }
        }
        
        return events.sort({ actualDates[$0]!.start <= actualDates[$1]!.start }).map { event in
            let duration = Event.Duration(rawValue: event.duration!.integerValue)!
            let category = Event.Category(rawValue: event.category!.integerValue)!
            let tags = event.tags!.isEmpty ? [] : event.tags!.componentsSeparatedByString(",")
            
            let actualStart = actualDates[event]!.start
            let actualEnd = actualDates[event]!.end
            var startTime = actualStart.stringOfDate
            var endTime = actualEnd.stringOfDate
            let time: String
            if startTime == endTime {
                if event.duration! == Event.Duration.PartialTime.rawValue {
                    startTime += " " + actualDates[event]!.start.stringOfTime
                    endTime = actualDates[event]!.end.stringOfTime
                    time = startTime + "-" + endTime
                } else {
                    time = startTime
                }
            } else {
                time = startTime + " - " + endTime
            }
            
            return Event(duration: duration, category: category, tags: tags, name: event.name!, time: time, place: event.place!, start: actualStart, end: actualEnd, object: event)
        }
    }
    
    public var allHomeworks: [Homework] {
        let request = NSFetchRequest(entityName: "Homework")
        let homeworks = try! managedObjectContext.executeFetchRequest(request) as! [Homework]
        return homeworks.sort { $0.deadline <= $1.deadline }
    }
    
    // MARK: - Creation & Deletion
    
    /**
     Create an event entity for the course with the given identifier. If that entity exists, this method will do nothing.
     
     - parameter identifier: Identifier of the course, e.g. "(2015-2016-2)-051F0090".
     */
    func createCourseEvent(identifier: String, teacher: String) {
        if courseEventForIdentifier(identifier) == nil {
            let courseEvent = CourseEvent(context: managedObjectContext)
            courseEvent.identifier = identifier
            courseEvent.teacher = teacher
            try! managedObjectContext.save()
        }
    }
    
    public var newCustomEvent: CustomEvent {
        return CustomEvent(context: managedObjectContext)
    }
    
    public func removeCustomEvent(event: CustomEvent) {
        managedObjectContext.deleteObject(event)
        try! managedObjectContext.save()
    }
    
    public func newHomeworkOfCourseEvent(courseEvent: CourseEvent) -> Homework {
        let hw = Homework(context: managedObjectContext)
        hw.courseEvent = courseEvent
        return hw
    }
    
    public func removeHomework(hw: Homework) {
        managedObjectContext.deleteObject(hw)
        try! managedObjectContext.save()
    }
    
    // MARK: - Save
    
    public func save() {
        try! managedObjectContext.save()
    }
    
}
