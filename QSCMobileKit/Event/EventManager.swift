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
        let modelURL = Bundle(identifier: QSCMobileKitIdentifier)!.url(forResource: "Event", withExtension: "momd")!
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIdentifier)!.appendingPathComponent("Event.sqlite")
        
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        return moc
    }()
    
    // MARK: - Retrieval
    
    /**
     Return the corresponding event for courses with the identifier.
     
     - parameter identifier: Whose first 22 characters are used as the identifier.
     
     - returns: The object of `CourseEvent`.
     */
    public func courseEventForIdentifier(_ identifier: String) -> CourseEvent? {
        let identifier = identifier.substring(to: identifier.index(identifier.startIndex, offsetBy: 22))
        
//        if #available(iOSApplicationExtension 10.0, *) {
//            let request: NSFetchRequest<CourseEvent> = CourseEvent.fetchRequest()
//        }
        let request: NSFetchRequest<CourseEvent> = NSFetchRequest(entityName: "CourseEvent")
        request.predicate = NSPredicate(format: "identifier CONTAINS %@", identifier)
        return try! managedObjectContext.fetch(request).first
    }
    
    public func customEventsForDate(_ date: Date) -> [Event] {
        var actualDates = [CustomEvent: (start: Date, end: Date)]()
        
        let request: NSFetchRequest<CustomEvent> = NSFetchRequest(entityName: "CustomEvent")
        request.predicate = NSPredicate(format: "(start < %@) AND (end >= %@)", date.tomorrow as NSDate, date.today as NSDate)
        var events = try! managedObjectContext.fetch(request)
        for event in events {
            actualDates[event] = (event.start!, event.end!)
        }
        
        request.predicate = NSPredicate(format: "(end < %@) AND (repeatType != \"永不\") AND (repeatEnd >= %@)", date.today as NSDate, date.today as NSDate)
        let repeatable = try! managedObjectContext.fetch(request)
        for event in repeatable {
            let startComponents: DateComponents
            switch event.repeatType! {
            case "每周", "每两周":
                startComponents = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: event.start!)
            case "每月":
                startComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: event.start!)
            default:
                startComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: event.start!)
            }
            let timeInterval = event.end!.timeIntervalSince(event.start!)
            var flag = false
            Calendar.current.enumerateDates(startingAfter: event.start!, matching: startComponents, matchingPolicy: .strict) { start, _, stop in
                if start! >= date.tomorrow {
                    stop = true
                    return
                }
                flag = !flag
                if event.repeatType == "每两周" && flag {
                    return
                }
                let end = start?.addingTimeInterval(timeInterval)
                if start! < date.tomorrow && end! >= date.today {
                    actualDates[event] = (start!, end!)
                    events.append(event)
                }
            }
        }
        
        return events.sorted(by: { actualDates[$0]!.start <= actualDates[$1]!.start }).map { event in
            let duration = Event.Duration(rawValue: event.duration!.intValue)!
            let category = Event.Category(rawValue: event.category!.intValue)!
            let tags = event.tags!.isEmpty ? [] : event.tags!.components(separatedBy: ",")
            
            let actualStart = actualDates[event]!.start
            var actualEnd = actualDates[event]!.end
            var startTime = actualStart.stringOfDate
            var endTime = actualEnd.stringOfDate
            let time: String
            if startTime == endTime {
                if event.duration!.intValue == Event.Duration.partialTime.rawValue {
                    startTime += " " + actualDates[event]!.start.stringOfTime
                    endTime = actualDates[event]!.end.stringOfTime
                    time = startTime + "-" + endTime
                } else {
                    time = startTime
                }
            } else {
                time = startTime + " - " + endTime
            }
            
            if event.duration!.intValue == Event.Duration.allDay.rawValue {
                actualEnd = actualEnd.tomorrow
            }
            
            return Event(duration: duration, category: category, tags: tags, name: event.name!, time: time, place: event.place!, start: actualStart, end: actualEnd, object: event)
        }
    }
    
    public var allHomeworks: [Homework] {
        let request: NSFetchRequest<Homework> = NSFetchRequest(entityName: "Homework")
        let homeworks = try! managedObjectContext.fetch(request)
        return homeworks.sorted { $0.deadline! >= $1.deadline! }
    }
    
    // MARK: - Creation & Deletion
    
    /**
     Create an event entity for the course with the given identifier. If that entity exists, this method will do nothing.
     
     - parameter identifier: Identifier of the course, e.g. "(2015-2016-2)-051F0090".
     */
    func createCourseEvent(_ identifier: String, teacher: String) {
        if courseEventForIdentifier(identifier) == nil {
//            if #available(iOSApplicationExtension 10.0, *) {
//                let courseEvent = CourseEvent(context: managedObjectContext)
//            }
            let courseEvent = NSEntityDescription.insertNewObject(forEntityName: "CourseEvent", into: managedObjectContext) as! CourseEvent
            courseEvent.identifier = identifier
            courseEvent.teacher = teacher
            try! managedObjectContext.save()
        }
    }
    
    public var newCustomEvent: CustomEvent {
        return NSEntityDescription.insertNewObject(forEntityName: "CustomEvent", into: managedObjectContext) as! CustomEvent
    }
    
    public func removeCustomEvent(_ event: CustomEvent) {
        managedObjectContext.delete(event)
        try! managedObjectContext.save()
    }
    
    public func newHomeworkOfCourseEvent(_ courseEvent: CourseEvent) -> Homework {
        let hw = NSEntityDescription.insertNewObject(forEntityName: "Homework", into: managedObjectContext) as! Homework
        hw.courseEvent = courseEvent
        return hw
    }
    
    public func removeHomework(_ hw: Homework) {
        managedObjectContext.delete(hw)
        try! managedObjectContext.save()
    }
    
    // MARK: - Save
    
    public func save() {
        try! managedObjectContext.save()
    }
    
}
