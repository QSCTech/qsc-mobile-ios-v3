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
    
    private static let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIdentifier)!.appendingPathComponent("Mobile.sqlite")
    
    private static let managedObjectContext: NSManagedObjectContext = {
        let modelURL = Bundle(identifier: QSCMobileKitIdentifier)!.url(forResource: "Mobile", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
    func createCourses(_ json: JSON) {
        for (_, json) in json {
            for (_, json) in json {
                let course = NSEntityDescription.insertNewObject(forEntityName: "Course", into: managedObjectContext) as! Course
                course.user = currentUser
                
                course.code = json["code"].stringValue.replacingOccurrences(of: "&#039;&#039;", with: " ")
                course.name = json["name"].stringValue.replacingOccurrences(of: "&#039;&#039;", with: "")
                course.teacher = json["teacher"].stringValue.replacingOccurrences(of: "&#039;&#039;", with: "")
                course.semester = json["semester"].stringValue
                course.isDetermined = json["determined"].numberValue
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
                course.credit = basicInfo["Credit"].numberValue
                course.englishName = basicInfo["EnglishName"].stringValue
                course.faculty = basicInfo["Faculty"].stringValue
                course.prerequisite = basicInfo["Prerequisite"].stringValue
                
                course.category = basicInfo["Category"].stringValue
                course.category = course.category!.replacingOccurrences(of: "\\", with: "/")
                if course.code!.hasPrefix("401") {
                    course.category = "体育课"
                } else if Int(course.code!) != nil {
                    course.category = course.faculty
                }
                
                EventManager.sharedInstance.createCourseEvent(course.identifier!, teacher: course.teacher!)
                
                for (_, json) in json["timePlace"] {
                    if json["course"].arrayValue.isEmpty {
                        continue
                    }
                    
                    let timePlace = NSEntityDescription.insertNewObject(forEntityName: "TimePlace", into: managedObjectContext) as! TimePlace
                    timePlace.course = course
                    timePlace.place = json["place"].stringValue.chomp("#").chomp("*")
                    
                    timePlace.time = ""
                    if let dayOfWeek = Int(json["dayOfWeek"].stringValue, radix:10) {
                        timePlace.weekday = (dayOfWeek % 7 + 1) as NSNumber
                        timePlace.time! += timePlace.weekday!.intValue.stringForWeekday
                    }
                    timePlace.week = json["week"].stringValue
                    if timePlace.week != "每周" {
                        timePlace.time! += " (\(timePlace.week!))"
                    }
                    
                    timePlace.periods = ""
                    let periods = json["course"].arrayValue
                    for period in periods {
                        timePlace.periods! += String(Int(period.stringValue, radix: 10)!, radix: 16)
                    }
                    timePlace.time! += " \(periods.first!.stringValue)\(periods.count == 1 ? "" : "-" + periods.last!.stringValue) 节"
                    let startTime = timePlace.periods!.startTimeForPeriods
                    let endTime = timePlace.periods!.endTimeForPeriods
                    timePlace.time! += String(format: " (%02d:%02d-%02d:%02d)", startTime.hour!, startTime.minute!, endTime.hour!, endTime.minute!)
                }
                
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create all exams in managed object context. Time and place may be empty for some exams.
     
     - parameter json: JSON of exams.
     */
    func createExams(_ json: JSON) {
        for (semester, json) in json {
            for (_, json) in json {
                
                let exam = NSEntityDescription.insertNewObject(forEntityName: "Exam", into: managedObjectContext) as! Exam
                exam.user = currentUser
                
                exam.credit = json["credit"].numberValue
                exam.identifier = json["identifier"].stringValue
                exam.isRelearning = json["isRelearning"].numberValue
                exam.name = json["name"].stringValue
                exam.place = (json["place"].string ?? "暂无考场信息").chomp("#").chomp("*")
                exam.seat = json["seat"].stringValue
                exam.semester = json["semester_real"].stringValue
                exam.time = json["time"].stringValue.replacingOccurrences(of: "(", with: " ").replacingOccurrences(of: ")", with: "")
                let yearIndex = semester.index(semester.startIndex, offsetBy: 9)
                exam.year = String(semester[..<yearIndex])
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                exam.startTime = formatter.date(from: json["timeStart"].stringValue)
                exam.endTime = formatter.date(from: json["timeEnd"].stringValue)
                
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create all scores including semester scores in managed object context.
     
     - parameter json: JSON of scores.
     */
    func createScores(_ json: JSON) {
        var creditSum = Float(0)
        var fourPointSum = Float(0)
        var hundredPointSum = Float(0)
        
        for (semester, json) in json["scoreObject"] {
            let semesterScore = NSEntityDescription.insertNewObject(forEntityName: "SemesterScore", into: managedObjectContext) as! SemesterScore
            semesterScore.user = currentUser
            
            let yearIndex = semester.index(semester.startIndex, offsetBy: 9)
            semesterScore.year = String(semester[..<yearIndex])
            let semesterIndex = semester.index(semester.endIndex, offsetBy: -2)
            semesterScore.semester = String(semester[semesterIndex...])
            semesterScore.totalCredit = json["totalCredit"].numberValue
            semesterScore.averageGrade = json["averageScore"].numberValue
            
            for (_, json) in json["scoreList"] {
                let score = NSEntityDescription.insertNewObject(forEntityName: "Score", into: managedObjectContext) as! Score
                score.user = currentUser
                
                let credit = json["credit"].floatValue
                
                let gradePoint = Float(json["gradePoint"].stringValue) ?? 0
                score.credit = credit as NSNumber
                score.identifier = json["identifier"].stringValue
                score.makeup = json["makeup"].stringValue
                score.name = json["name"].stringValue
                score.gradePoint = gradePoint as NSNumber
                score.score = json["score"].stringValue
                score.year = semesterScore.year!
                score.semester = semesterScore.semester!
                
                creditSum += credit
                fourPointSum += (gradePoint > 4 ? 4 : gradePoint) * credit
                if let score = Float(score.score!) {
                    hundredPointSum += score * credit
                } else {
                    hundredPointSum += (gradePoint == 0 ? 0 : gradePoint * 10 + 45) * credit
                }
            }
        }
        
        let overseaScore = NSEntityDescription.insertNewObject(forEntityName: "OverseaScore", into: managedObjectContext) as! OverseaScore
        overseaScore.user = currentUser
        overseaScore.fourPoint = (fourPointSum / creditSum) as NSNumber
        overseaScore.hundredPoint = (hundredPointSum / creditSum) as NSNumber
        
        try! managedObjectContext.save()
    }
    
    /**
     Create statistics in managed object context.
     
     - parameter json: JSON of statistics.
     */
    func createStatistics(_ json: JSON) {
        let statistics = NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: managedObjectContext) as! Statistics
        statistics.user = currentUser
        
        statistics.totalCredit = json["totalCredit"].numberValue
        statistics.averageGrade = json["averageGradePoint"].numberValue
        statistics.majorCredit = json["totalCreditMajor"].numberValue
        statistics.majorGrade = json["averageGradePointMajor"].numberValue
        
        try! managedObjectContext.save()
    }
    
    /**
     Create calendar in managed object context.
     
     - parameter json: JSON of calendar.
     */
    func createCalendar(_ json: JSON) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        
        for (key, json) in json {
            let year = NSEntityDescription.insertNewObject(forEntityName: "Year", into: managedObjectContext) as! Year
            year.name = key
            year.start = formatter.date(from: json["start"].stringValue)
            year.end = formatter.date(from: json["end"].stringValue)
            
            for (key, json) in json["semesters"] {
                if CalendarSemester(rawValue: key) == nil {
                    continue
                }
                
                let semester = NSEntityDescription.insertNewObject(forEntityName: "Semester", into: managedObjectContext) as! Semester
                semester.year = year
                
                semester.name = key
                semester.start = formatter.date(from: json["start"].stringValue)
                semester.end = formatter.date(from: json["end"].stringValue)
                semester.startsWithWeekZero = json["startsWithWeekZero"].numberValue
            }
            for (_, json) in json["holidays"] {
                let holiday = NSEntityDescription.insertNewObject(forEntityName: "Holiday", into: managedObjectContext) as! Holiday
                holiday.year = year
                
                holiday.name = json["name"].stringValue
                holiday.start = formatter.date(from: json["start"].stringValue)
                holiday.end = formatter.date(from: json["end"].stringValue)
            }
            for (_, json) in json["adjustments"] {
                let adjustment = NSEntityDescription.insertNewObject(forEntityName: "Adjustment", into: managedObjectContext) as! Adjustment
                adjustment.year = year
                
                adjustment.name = json["name"].stringValue
                adjustment.fromStart = formatter.date(from: json["fromStart"].stringValue)
                adjustment.fromEnd = formatter.date(from: json["fromEnd"].stringValue)
                adjustment.toStart = formatter.date(from: json["toStart"].stringValue)
                adjustment.toEnd = formatter.date(from: json["toEnd"].stringValue)
            }
            for (_, json) in json["special"] {
                let special = NSEntityDescription.insertNewObject(forEntityName: "Special", into: managedObjectContext) as! Special
                special.year = year
                
                special.code = json["code"].stringValue
                special.weekly = json["weekly"].stringValue
                special.date = formatter.date(from: json["date"].stringValue)
                
                if special.weekly! == "odd" {
                    special.weekly! = "单"
                } else if special.weekly! == "even" {
                    special.weekly! = "双"
                } else {
                    special.weekly! = "每周"
                }
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create information of buses and stops in managed object context.
     
     - parameter json: JSON of buses.
     */
    func createBuses(_ json: JSON) {
        for (_, json) in json {
            let bus = NSEntityDescription.insertNewObject(forEntityName: "Bus", into: managedObjectContext) as! Bus
            bus.name = json["name"].stringValue
            bus.serviceDays = json["serviceDays"].stringValue
            bus.note = json["note"].stringValue
            
            for (index, json) in json["stops"] {
                let busStop = NSEntityDescription.insertNewObject(forEntityName: "BusStop", into: managedObjectContext) as! BusStop
                busStop.bus = bus
                
                busStop.campus = json["campus"].stringValue
                busStop.time = json["time"].stringValue
                busStop.location = json["location"].stringValue
                busStop.index = Int(index, radix: 10)! as NSNumber
            }
        }
        try! managedObjectContext.save()
    }
    
    /**
     Create a entity for given username. If the user exists, it will return immediately.
     
     - parameter username: Username of the user.
     */
    static func createUser(_ username: String) {
        if DataStore.entityForUser(username) != nil {
            return
        }
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as! User
        user.sid = username
        try! managedObjectContext.save()
    }
    
    // MARK: - Deletion
    
    /**
     Delete all entities with the specified name.
     
     - parameter entityName: The name of entities.
     */
    private static func deleteEntities(_ entityName: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! managedObjectContext.persistentStoreCoordinator!.execute(deleteRequest, with: managedObjectContext)
    }
    
    /**
     Delete all data about calendar.
     */
    func deleteCalendar() {
        DataStore.deleteEntities("Year")
        DataStore.deleteEntities("Semester")
        DataStore.deleteEntities("Holiday")
        DataStore.deleteEntities("Adjustment")
        DataStore.deleteEntities("Special")
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
                managedObjectContext.delete(timePlace)
            }
            managedObjectContext.delete(course)
        }
        try! managedObjectContext.save()
    }
    
    /**
     Delete all exams of current user.
     */
    func deleteExams() {
        for exam in currentUser.exams! {
            let exam = exam as! Exam
            managedObjectContext.delete(exam)
        }
        try! managedObjectContext.save()
    }
    
    /**
     Delete all scores of current user.
     */
    func deleteScores() {
        if let overseaScore = currentUser.overseaScore {
            managedObjectContext.delete(overseaScore)
        }
        for semesterScore in currentUser.semesterScores! {
            let semesterScore = semesterScore as! SemesterScore
            managedObjectContext.delete(semesterScore)
        }
        for score in currentUser.scores! {
            let score = score as! Score
            managedObjectContext.delete(score)
        }
        try! managedObjectContext.save()
    }
    
    /**
     Delete statistics of current user.
     */
    func deleteStatistics() {
        if let statistics = currentUser.statistics {
            managedObjectContext.delete(statistics)
            try! managedObjectContext.save()
        }
    }
    
    /**
     Delete current user entity, after which you should release DataStore instance ASAP.
     */
    func deleteUser() {
        managedObjectContext.delete(currentUser)
        try! managedObjectContext.save()
    }
    
    // MARK: - Retrieval
    
    /**
     Retrieve current user's courses with the specified semester.
    
     - returns: An unsorted array of courses.
    */
    func getCourses(year: String, semester: CalendarSemester) -> [Course] {
        return currentUser.courses!.filter {
            let course = $0 as! Course
            return course.isDetermined!.boolValue && course.year == year && course.semester!.includesSemester(semester)
        } as! [Course]
    }
    
    /**
     Retrieve current user's exams with the specified semester.
     
     - returns: An unsorted array of exams.
     */
    func getExams(year: String, semester: CalendarSemester) -> [Exam] {
        return currentUser.exams!.filter {
            let exam = $0 as! Exam
            return exam.year == year && exam.semester!.includesSemester(semester)
        } as! [Exam]
    }
    
    /**
     Retrieve current user's scores with the specified semester.
     
     - returns: An unsorted array of scores.
     */
    func getScores(year: String, semester: CalendarSemester) -> [Score] {
        return currentUser.scores!.filter {
            let score = $0 as! Score
            return score.year == year && score.semester!.includesSemester(semester)
        } as! [Score]
    }
    
    var semesterScores: [SemesterScore] {
        let descriptors = [NSSortDescriptor(key: "year", ascending: true), NSSortDescriptor(key: "semester", ascending: true)]
        return currentUser.semesterScores!.sortedArray(using: descriptors) as! [SemesterScore]
    }
    
    var statistics: Statistics? {
        return currentUser.statistics
    }
    
    var overseaScore: OverseaScore? {
        return currentUser.overseaScore
    }
    
    /// All semesters in which the current user has studied.
    var allSemesters: [String] {
        if let start = currentUser.startSemester, let end = currentUser.endSemester {
            var semesters = [start]
            while semesters.last != end {
                var current = semesters.last!
                if current.hasSuffix("1") {
                    let index = current.index(before: current.endIndex)
                    current = current[..<index] + "2"
                } else {
                    let index = current.index(current.startIndex, offsetBy: 4)
                    let year = Int(current[..<index])!
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
    static func busStopsOnCampus(_ campus: String) -> [BusStop] {
        let request: NSFetchRequest<BusStop> = NSFetchRequest(entityName: "BusStop")
        request.predicate = NSPredicate(format: "campus == %@", campus)
        let stops = try! managedObjectContext.fetch(request)
        return stops.sorted {
            if $0.time == "*" || $1.time == "*" {
                return $1.time == "*"
            } else {
                return $0.time! <= $1.time!
            }
        }
    }
    
    static func entityForYear(_ date: Date) -> Year? {
        let request: NSFetchRequest<Year> = NSFetchRequest(entityName: "Year")
        request.predicate = NSPredicate(format: "(start <= %@) AND (%@ < end)", date as NSDate, date as NSDate)
        return try! managedObjectContext.fetch(request).first
    }
    
    static func entityForUser(_ username: String) -> User? {
        let request: NSFetchRequest<User> = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "sid == %@", username)
        return try! managedObjectContext.fetch(request).first
    }
    
    /**
     Retrieve all proper managed objects with the identifier prefix.
     
     - parameter identifier: The identifier used as prefix.
     - parameter entityName: The name of the entity.
     
     - returns: The unsorted array of managed objects.
     */
    func objectsWithIdentifier(_ identifier: String, entityName: String) -> [NSManagedObject] {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "user.sid == %@ AND identifier LIKE %@", currentUser.sid!, identifier + "*")
        return try! managedObjectContext.fetch(request) as! [NSManagedObject]
    }
    
    // MARK: - SQLite Management
    
    static func dropSqlite() {
        let removeFile = { (path: String) -> Void in
            if FileManager.default.fileExists(atPath: path) {
                try! FileManager.default.removeItem(atPath: path)
            }
        }
        removeFile(storeURL.path)
        removeFile(storeURL.path + "-wal")
        removeFile(storeURL.path + "-shm")
    }
    
    static var sizeOfSqlite: String {
        let sizeOfFile = { (path: String) -> Int64 in
            if FileManager.default.fileExists(atPath: path) {
                return Int64((try! FileManager.default.attributesOfItem(atPath: path) as NSDictionary).fileSize())
            } else {
                return 0
            }
        }
        let size = sizeOfFile(storeURL.path) + sizeOfFile(storeURL.path + "-wal") + sizeOfFile(storeURL.path + "-shm")
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
}
