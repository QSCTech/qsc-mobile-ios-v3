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
        
        super.init()
        
        setUser(AccountManager.sharedInstance.currentAccountForJwbinfosys!)
    }
    
    static let sharedInstance = CoreDataManager()
    
    var managedObjectContext: NSManagedObjectContext
    var currentUser: User!
    
    func setUser(username: String) {
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "sid == ", username)
        currentUser = try! managedObjectContext.executeFetchRequest(fetchRequest).first! as! User
    }
    
    // MARK: - Creation
    
    /**
      Create all courses in managed object context.
     
     - parameter json: JSON of courses.
     */
    func createCourses(json: JSON) {
        for (_, json) in json {
            for (_, json) in json {
                
                let course = Course(context: managedObjectContext)
                course.user = currentUser
                
                course.code = json["code"].stringValue
                course.name = json["name"].stringValue
                course.teacher = json["teacher"].stringValue
                course.semester = json["semester"].stringValue
                course.determined = json["determined"].boolValue
                course.identifier = json["hash"].stringValue
                course.year = json["year"].stringValue
                
                let basicInfo = json["basicInfo"]
                course.credit = basicInfo["Credit"].floatValue
                course.englishName = basicInfo["EnglishName"].stringValue
                course.faculty = basicInfo["Faculty"].stringValue
                course.category = basicInfo["Category"].stringValue
                
                for (_, json) in json["timePlace"] {
                    let timePlace = TimePlace(context: managedObjectContext)
                    timePlace.course = course
                    
                    timePlace.place = json["place"].stringValue
                    
                    timePlace.week = json["week"].stringValue
                    timePlace.time = timePlace.week
                    
                    timePlace.weekday = Int(json["dayOfWeek"].stringValue, radix: 10)! % 7 + 1
                    timePlace.time! += timePlace.weekday!.stringForWeekday
                    
                    timePlace.periods = ""
                    for (_, period) in json["course"] {
                        timePlace.periods! += String(Int(period.stringValue, radix: 10)!, radix: 16)
                    }
                    timePlace.time! += " \(json["course"].arrayValue.map({ $0.string! }).joinWithSeparator("/")) 节"
                    let startTime = timePlace.periods!.startTimeForPeriods
                    let endTime = timePlace.periods!.endTimeForPeriods
                    timePlace.time! += "（\(startTime.hour):\(startTime.minute) - \(endTime.hour):\(endTime.minute)）"
                }
                
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create all exams in managed object context.
     
     - parameter json: JSON of exams.
     */
    func createExams(json: JSON) {
        for (_, json) in json {
            for (_, json) in json {
                
                let exam = Exam(context: managedObjectContext)
                exam.user = currentUser
                
                exam.credit = json["credit"].floatValue
                exam.identifier = json["identifier"].stringValue
                exam.isRelearning = json["isRelearning"].boolValue
                exam.name = json["name"].stringValue
                exam.place = json["name"].stringValue
                exam.seat = json["seat"].stringValue
                exam.semester = json["semester_real"].stringValue
                exam.time = json["time"].stringValue
                
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                exam.startTime = formatter.dateFromString(json["timeStart"].stringValue)
                exam.endTime = formatter.dateFromString(json["timeEnd"].stringValue)
                
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create a single score in managed object context. Note this is a private helper for `createSemesterScores()`.
     
     - parameter json: JSON of a single score.
     */
    private func createScore(json: JSON) {
        let score = Score(context: managedObjectContext)
        score.user = currentUser
        
        score.credit = json["credit"].floatValue
        score.identifier = json["identifier"].stringValue
        score.makeup = json["makeup"].stringValue
        score.name = json["name"].stringValue
        score.gradePoint = (json["gradePoint"].stringValue as NSString).floatValue
        score.score = Int(json["score"].stringValue, radix:10)
    }
    
    /**
     Create all scores including semester scores in managed object context.
     
     - parameter json: JSON of scores.
     */
    func createSemesterScores(json: JSON) {
        for (semester, json) in json["scoreObject"] {
            let semesterScore = SemesterScore(context: managedObjectContext)
            semesterScore.user = currentUser
            
            semesterScore.year = semester.substringToIndex(semester.startIndex.advancedBy(9))
            semesterScore.semester = semester.substringFromIndex(semester.endIndex.advancedBy(-2))
            semesterScore.totalCredit = json["totalCredit"].floatValue
            semesterScore.averageGrade = json["averageScore"].floatValue
            
            for (_, score) in json["scoreList"] {
                createScore(score)
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create statistics in managed object context.
     
     - parameter json: JSON of statistics.
     */
    func createStatistics(json: JSON) {
        currentUser.totalCredit = json["totalCredit"].floatValue
        currentUser.averageGrade = json["averageGradePoint"].floatValue
        currentUser.majorCredit = json["totalCreditMajor"].floatValue
        currentUser.majorGrade = json["averageGradePointMajor"].floatValue
        try! managedObjectContext.save()
    }
    
    /**
     Create calendar in managed object context.
     
     - parameter json: JSON of calendar.
     */
    func createCalendar(json: JSON) {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mmz"
        
        for (key, json) in json {
            let year = Year(context: managedObjectContext)
            year.name = key
            year.start = formatter.dateFromString(json["start"].stringValue)
            year.end = formatter.dateFromString(json["end"].stringValue)
            
            for (key, json) in json["semesters"] {
                let semester = Semester(context: managedObjectContext)
                semester.year = year
                
                semester.name = key
                semester.start = formatter.dateFromString(json["start"].stringValue)
                semester.end = formatter.dateFromString(json["end"].stringValue)
                semester.startsWithWeekZero = json["startsWithWeekZero"].boolValue
            }
            for (_, json) in json["holidays"] {
                let holiday = Holiday(context: managedObjectContext)
                holiday.year = year
                
                holiday.name = json["name"].stringValue
                holiday.start = formatter.dateFromString(json["start"].stringValue)
                holiday.end = formatter.dateFromString(json["end"].stringValue)
            }
            for (_, json) in json["adjustments"] {
                let adjustment = Adjustment(context: managedObjectContext)
                adjustment.year = year
                
                adjustment.name = json["name"].stringValue
                adjustment.fromStart = formatter.dateFromString(json["fromStart"].stringValue)
                adjustment.fromEnd = formatter.dateFromString(json["fromEnd"].stringValue)
                adjustment.toStart = formatter.dateFromString(json["toStart"].stringValue)
                adjustment.toEnd = formatter.dateFromString(json["toEnd"].stringValue)
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create information of buses and stops in managed object context.
     
     - parameter json: JSON of buses.
     */
    func createBuses(json: JSON) {
        for (_, json) in json {
            let bus = Bus(context: managedObjectContext)
            bus.name = json["name"].stringValue
            bus.serviceDays = json["serviceDays"].stringValue
            bus.note = json["note"].stringValue
            
            for (index, json) in json["stops"] {
                let busStop = BusStop(context: managedObjectContext)
                busStop.bus = bus
                
                busStop.campus = json["campus"].stringValue
                busStop.time = json["time"].stringValue
                busStop.location = json["time"].stringValue
                busStop.index = Int(index, radix: 10)
            }
        }
        try! managedObjectContext.save()
    }
    
    // MARK: - Deletion
    
    /**
     Delete all entities with the specified name. This method uses APIs only available on iOS 9.0 or newer.
     
     - parameter entityName: The name of entities.
     */
    private func deleteEntities(entityName: String) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if #available(iOSApplicationExtension 9.0, *) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! managedObjectContext.persistentStoreCoordinator!.executeRequest(deleteRequest, withContext: managedObjectContext)
        } else {
            fetchRequest.includesPropertyValues = false
            let entities = try! managedObjectContext.executeFetchRequest(fetchRequest)
            for entity in entities {
                managedObjectContext.deleteObject(entity as! NSManagedObject)
            }
            try! managedObjectContext.save()
        }
    }
    
    func deleteCourses() {
        deleteEntities("Course")
        deleteEntities("TimePlace")
    }
    
    func deleteExams() {
        deleteEntities("Exam")
    }
    
    func deleteScores() {
        deleteEntities("SemesterScore")
        deleteEntities("Score")
    }
    
    func deleteCalendar() {
        deleteEntities("Year")
        deleteEntities("Semester")
        deleteEntities("Holiday")
        deleteEntities("Adjustment")
    }
    
    func deleteBuses() {
        deleteEntities("Bus")
        deleteEntities("BusStop")
    }
    
}
