//
//  DataStore.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-30.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

/// The CoreData store manager, used by mobile manager. Make sure the corresponding user entity exists, otherwise initialization will crash.
class DataStore: NSObject {
    
    init(username: String) {
        currentUser = DataStore.entityForUser(username)!
        
        super.init()
    }
    
    private static let storeURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(AppGroupIdentifier)!.URLByAppendingPathComponent("Mobile.sqlite")
    
    private static let managedObjectContext: NSManagedObjectContext = {
        let modelURL = NSBundle(identifier: QSCMobileKitIdentifier)!.URLForResource("Mobile", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOfURL: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        return moc
    }()
    // Defined as both type property and instance property to make it easy to use within either method.
    private let managedObjectContext: NSManagedObjectContext = DataStore.managedObjectContext
    
    private let currentUser: User
    
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
                course.isDetermined = json["determined"].boolValue
                course.year = json["year"].stringValue
                
                if course.semester!.includesSemester(.Spring) || course.semester!.includesSemester(.Summer) {
                    course.identifier = course.year! + "-2"
                } else {
                    course.identifier = course.year! + "-1"
                }
                currentUser.startSemester = currentUser.startSemester ?? course.identifier!
                if course.identifier! < currentUser.startSemester! {
                    currentUser.startSemester = course.identifier
                }
                currentUser.endSemester = currentUser.endSemester ?? course.identifier!
                if course.identifier! > currentUser.endSemester! {
                    currentUser.endSemester = course.identifier
                }
                course.identifier = "(\(course.identifier!))-\(course.code!)"
                
                let basicInfo = json["basicInfo"]
                course.credit = basicInfo["Credit"].floatValue
                course.englishName = basicInfo["EnglishName"].stringValue
                course.faculty = basicInfo["Faculty"].stringValue
                course.prerequisite = basicInfo["Prerequisite"].stringValue
                
                course.category = basicInfo["Category"].stringValue
                course.category = course.category!.stringByReplacingOccurrencesOfString("\\", withString: "/")
                if course.code!.hasPrefix("401") {
                    course.category = "体育课"
                } else if Int(course.code!) != nil {
                    course.category = course.faculty
                }
                
                EventManager.sharedInstance.createCourseEvent(course.identifier!, teacher: course.teacher!)
                
                for (_, json) in json["timePlace"] {
                    if json["course"].array == nil {
                        continue
                    }
                    let timePlace = TimePlace(context: managedObjectContext)
                    timePlace.course = course
                    timePlace.place = json["place"].stringValue.chomp("#").chomp("*")
                    
                    timePlace.time = ""
                    if let dayOfWeek = Int(json["dayOfWeek"].stringValue, radix:10) {
                        timePlace.weekday = dayOfWeek % 7 + 1
                        timePlace.time! += timePlace.weekday!.integerValue.stringForWeekday
                    }
                    timePlace.week = json["week"].stringValue
                    if timePlace.week != "每周" {
                        timePlace.time! += " (\(timePlace.week!))"
                    }
                    
                    timePlace.periods = ""
                    for (_, period) in json["course"] {
                        timePlace.periods! += String(Int(period.stringValue, radix: 10)!, radix: 16)
                    }
                    timePlace.time! += " \(json["course"].arrayValue.map({ $0.string! }).joinWithSeparator("/")) 节"
                    let startTime = timePlace.periods!.startTimeForPeriods
                    let endTime = timePlace.periods!.endTimeForPeriods
                    timePlace.time! += String(format: " (%02d:%02d-%02d:%02d)", startTime.hour, startTime.minute, endTime.hour, endTime.minute)
                }
                
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create all exams in managed object context. Time and place may be empty for some exams.
     
     - parameter json: JSON of exams.
     */
    func createExams(json: JSON) {
        for (semester, json) in json {
            for (_, json) in json {
                
                let exam = Exam(context: managedObjectContext)
                exam.user = currentUser
                
                exam.credit = json["credit"].floatValue
                exam.identifier = json["identifier"].stringValue
                exam.isRelearning = json["isRelearning"].boolValue
                exam.name = json["name"].stringValue
                exam.place = (json["place"].string ?? "暂无考场信息").chomp("#").chomp("*")
                exam.seat = json["seat"].stringValue
                exam.semester = json["semester_real"].stringValue
                exam.time = json["time"].stringValue.stringByReplacingOccurrencesOfString("(", withString: " ").stringByReplacingOccurrencesOfString(")", withString: "")
                exam.year = semester.substringToIndex(semester.startIndex.advancedBy(9))
                
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
     
     - parameter json:     JSON of a single score.
     - parameter year:     A string representing the academic year.
     - parameter semester: A string representing the semester.
     */
    private func createScore(json: JSON, year: String, semester: String) {
        let score = Score(context: managedObjectContext)
        score.user = currentUser
        
        score.credit = json["credit"].floatValue
        score.identifier = json["identifier"].stringValue
        score.makeup = json["makeup"].stringValue
        score.name = json["name"].stringValue
        score.gradePoint = Float(json["gradePoint"].stringValue)
        score.score = json["score"].stringValue
        score.year = year
        score.semester = semester
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
                createScore(score, year: semesterScore.year!, semester: semesterScore.semester!)
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create statistics in managed object context.
     
     - parameter json: JSON of statistics.
     */
    func createStatistics(json: JSON) {
        let statistics = Statistics(context: managedObjectContext)
        statistics.user = currentUser
        
        statistics.totalCredit = json["totalCredit"].floatValue
        statistics.averageGrade = json["averageGradePoint"].floatValue
        statistics.majorCredit = json["totalCreditMajor"].floatValue
        statistics.majorGrade = json["averageGradePointMajor"].floatValue
        
        try! managedObjectContext.save()
    }
    
    /**
     Create calendar in managed object context.
     
     - parameter json: JSON of calendar.
     */
    func createCalendar(json: JSON) {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 28800) // APIv3
        formatter.dateFormat = "yyyy-MM-dd"
        
        for (key, json) in json {
            let year = Year(context: managedObjectContext)
            year.name = key
            year.start = formatter.dateFromString(json["start"].stringValue)
            year.end = formatter.dateFromString(json["end"].stringValue)
            
            for (key, json) in json["semesters"] {
                if CalendarSemester(rawValue: key) == nil {
                    continue
                }
                
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
                busStop.location = json["location"].stringValue
                busStop.index = Int(index, radix: 10)
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create a entity for given username. If the user exists, it will return immediately.
     
     - parameter username: Username of the user.
     */
    static func createUser(username: String) {
        if DataStore.entityForUser(username) != nil {
            return
        }
        let user = User(context: managedObjectContext)
        user.sid = username
        try! managedObjectContext.save()
    }
    
    // MARK: - Deletion
    
    /**
     Delete all entities with the specified name.
     
     - parameter entityName: The name of entities.
     */
    private static func deleteEntities(entityName: String) {
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
    
    /**
     Delete all data about calendar.
     */
    func deleteCalendar() {
        DataStore.deleteEntities("Year")
        DataStore.deleteEntities("Semester")
        DataStore.deleteEntities("Holiday")
        DataStore.deleteEntities("Adjustment")
    }
    
    /**
     Delete all data about school buses.
     */
    func deleteBuses() {
        DataStore.deleteEntities("Bus")
        DataStore.deleteEntities("BusStop")
    }
    
    /**
     Delete all courses of current user.
     */
    func deleteCourses() {
        for course in currentUser.courses! {
            let course = course as! Course
            for timePlace in course.timePlaces! {
                let timePlace = timePlace as! TimePlace
                managedObjectContext.deleteObject(timePlace)
            }
            managedObjectContext.deleteObject(course)
        }
        try! managedObjectContext.save()
    }
    
    /**
     Delete all exams of current user.
     */
    func deleteExams() {
        for exam in currentUser.exams! {
            let exam = exam as! Exam
            managedObjectContext.deleteObject(exam)
        }
        try! managedObjectContext.save()
    }
    
    /**
     Delete all scores of current user.
     */
    func deleteScores() {
        for semesterScore in currentUser.semesterScores! {
            let semesterScore = semesterScore as! SemesterScore
            managedObjectContext.deleteObject(semesterScore)
        }
        for score in currentUser.scores! {
            let score = score as! Score
            managedObjectContext.deleteObject(score)
        }
        try! managedObjectContext.save()
    }
    
    /**
     Delete statistics of current user.
     */
    func deleteStatistics() {
        if let statistics = currentUser.statistics {
            managedObjectContext.deleteObject(statistics)
            try! managedObjectContext.save()
        }
    }
    
    /**
     Delete current user entity, after which you should release DataStore instance ASAP.
     */
    func deleteUser() {
        managedObjectContext.deleteObject(currentUser)
        try! managedObjectContext.save()
    }
    
    // MARK: - Retrieval
    
    /**
     Retrieve current user's courses with the specified semester.
    
     - returns: An unsorted array of courses.
    */
    func getCourses(year year: String, semester: CalendarSemester) -> [Course] {
        return currentUser.courses!.filter {
            let course = $0 as! Course
            return course.isDetermined!.boolValue && course.year == year && course.semester!.includesSemester(semester)
        } as! [Course]
    }
    
    /**
     Retrieve current user's exams with the specified semester.
     
     - returns: An unsorted array of exams.
     */
    func getExams(year year: String, semester: CalendarSemester) -> [Exam] {
        return currentUser.exams!.filter {
            let exam = $0 as! Exam
            return exam.year == year && exam.semester!.includesSemester(semester)
        } as! [Exam]
    }
    
    /**
     Retrieve current user's scores with the specified semester.
     
     - returns: An unsorted array of scores.
     */
    func getScores(year year: String, semester: CalendarSemester) -> [Score] {
        return currentUser.scores!.filter {
            let score = $0 as! Score
            return score.year == year && score.semester!.includesSemester(semester)
        } as! [Score]
    }
    
    var semesterScores: [SemesterScore] {
        let descriptors = [NSSortDescriptor(key: "year", ascending: true), NSSortDescriptor(key: "semester", ascending: true)]
        return currentUser.semesterScores!.sortedArrayUsingDescriptors(descriptors) as! [SemesterScore]
    }
    
    var statistics: Statistics {
        return currentUser.statistics!
    }
    
    /// All semesters in which the current user has studied.
    var allSemesters: [String] {
        if let start = currentUser.startSemester, end = currentUser.endSemester {
            var semesters = [start]
            while semesters.last != end {
                var current = semesters.last!
                if current.hasSuffix("1") {
                    current = current.substringToIndex(current.endIndex.predecessor()) + "2"
                } else {
                    let year = Int(current.substringToIndex(current.startIndex.advancedBy(4)))!
                    current = "\(year + 1)-\(year + 2)-1"
                }
                semesters.append(current)
            }
            return semesters
        } else {
            return []
        }
    }
    
    /**
     Return all bus stops on the specific campus.
     
     - parameter campus: The name of the campus.
     
     - returns: An array of bus stops sorted by estimated time of arrival.
     */
    static func busStopsOnCampus(campus: String) -> [BusStop] {
        let request = NSFetchRequest(entityName: "BusStop")
        request.predicate = NSPredicate(format: "campus == %@", campus)
        let stops = try! managedObjectContext.executeFetchRequest(request) as! [BusStop]
        return stops.sort { $1.time == "*" || ($0.time != "*" && $0.time! <= $1.time!) }
    }
    
    static func entityForYear(date: NSDate) -> Year? {
        let fetchRequest = NSFetchRequest(entityName: "Year")
        fetchRequest.predicate = NSPredicate(format: "%@ BETWEEN { start, end }", date)
        return try! managedObjectContext.executeFetchRequest(fetchRequest).first as? Year
    }
    
    static func entityForUser(username: String) -> User? {
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "sid == %@", username)
        return try! managedObjectContext.executeFetchRequest(fetchRequest).first as? User
    }
    
    /**
     Retrieve all proper managed objects with the identifier prefix.
     
     - parameter identifier: The identifier used as prefix.
     - parameter entityName: The name of the entity.
     
     - returns: The unsorted array of managed objects.
     */
    func objectsWithIdentifier(identifier: String, entityName: String) -> [NSManagedObject] {
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "user.sid == %@ AND identifier LIKE %@", currentUser.sid!, identifier + "*")
        return try! managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
    }
    
    // MARK: - SQLite Management
    
    static func dropSqlite() {
        let removeFile = { (path: String) -> Void in
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                try! NSFileManager.defaultManager().removeItemAtPath(path)
            }
        }
        removeFile(storeURL.path!)
        removeFile(storeURL.path! + "-wal")
        removeFile(storeURL.path! + "-shm")
    }
    
    static var sizeOfSqlite: String {
        let sizeOfFile = { (path: String) -> Int64 in
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                return Int64((try! NSFileManager.defaultManager().attributesOfItemAtPath(path) as NSDictionary).fileSize())
            } else {
                return 0
            }
        }
        let size = sizeOfFile(storeURL.path!) + sizeOfFile(storeURL.path! + "-wal") + sizeOfFile(storeURL.path! + "-shm")
        return NSByteCountFormatter.stringFromByteCount(size, countStyle: .File)
    }
    
}
