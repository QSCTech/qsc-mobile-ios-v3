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
        
        let currentAccount = AccountManager.sharedInstance.currentAccountForJwbinfosys!
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "sid == ", currentAccount)
        currentUser = try! managedObjectContext.executeFetchRequest(fetchRequest).first! as! User
        
        super.init()
    }
    
    static let sharedInstance = CoreDataManager()
    
    var managedObjectContext: NSManagedObjectContext
    var currentUser: User
    
    /**
      Create all courses in managed object context.
     
     - parameter json: JSON of a course.
     */
    func createCourses(json: JSON) {
        for (_, courses) in json.dictionary! {
            for json in courses.array! {
                
                let course = Course(context: managedObjectContext)
                currentUser.addCourseObject(course)
                
                course.code = json["code"].string
                course.name = json["name"].string
                course.teacher = json["teacher"].string
                course.semester = json["semester"].string
                course.determined = json["determined"].bool
                course.identifier = json["hash"].string
                course.year = json["year"].string
                
                let basicInfo = json["basicInfo"]
                course.credit = basicInfo["Credit"].float
                course.englishName = basicInfo["EnglishName"].string
                course.faculty = basicInfo["Faculty"].string
                course.category = basicInfo["Category"].string
                
                if let array = json["timePlace"].array {
                    for item in array {
                        let timePlace = TimePlace(context: managedObjectContext)
                        timePlace.place = item["place"].string
                        
                        timePlace.week = item["week"].string
                        timePlace.time = timePlace.week
                        
                        timePlace.weekday = Int(item["dayOfWeek"].string!, radix: 10)! % 7 + 1
                        timePlace.time! += timePlace.weekday!.stringForWeekday
                        
                        timePlace.periods = ""
                        for period in item["course"].array! {
                            timePlace.periods! += String(Int(period.string!, radix: 10)!, radix: 16)
                        }
                        timePlace.time! += " \(item["course"].array!.map({ $0.string! }).joinWithSeparator("/")) 节"
                        let startTime = timePlace.periods!.startTimeForPeriods
                        let endTime = timePlace.periods!.endTimeForPeriods
                        timePlace.time! += "（\(startTime.hour):\(startTime.minute) - \(endTime.hour):\(endTime.minute)）"
                        
                        course.addTimePlaceObject(timePlace)
                    }
                }
                
            }
        }
    }
    
    func createExams(json: JSON) {
        for (_, exams) in json.dictionary! {
            for json in exams.array! {
        
                let exam = Exam(context: managedObjectContext)
                currentUser.addExamObject(exam)
                
                exam.credit = json["credit"].float
                exam.identifier = json["identifier"].string
                exam.isRelearning = json["isRelearning"].bool
                exam.name = json["name"].string
                exam.place = json["name"].string
                exam.seat = json["seat"].string
                exam.semester = json["semester_real"].string
                exam.time = json["time"].string
                
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                exam.startTime = formatter.dateFromString(json["timeStart"].string!)
                exam.endTime = formatter.dateFromString(json["timeEnd"].string!)
                
            }
        }
    }
    
    private func createScore(json: JSON) {
        let score = Score(context: managedObjectContext)
        currentUser.addScoreObject(score)
        
        score.credit = json["credit"].float
        score.identifier = json["identifier"].string
        score.makeup = json["makeup"].string
        score.name = json["name"].string
        score.gradePoint = (json["gradePoint"].string! as NSString).floatValue
        score.score = Int(json["score"].string!, radix:10)
    }
    
    func createSemesterScores(json: JSON) {
        for (semester, json) in json["scoreObject"].dictionary! {
            let semesterScore = SemesterScore(context: managedObjectContext)
            currentUser.addSemesterScoreObject(semesterScore)
            
            semesterScore.year = semester.substringToIndex(semester.startIndex.advancedBy(9))
            semesterScore.semester = semester.substringFromIndex(semester.endIndex.advancedBy(-2))
            semesterScore.totalCredit = json["totalCredit"].float
            semesterScore.averageGrade = json["averageScore"].float
            
            for score in json["scoreList"].array! {
                createScore(score)
            }
        }
    }
    
    func createStatistics(json: JSON) {
        currentUser.totalCredit = json["totalCredit"].float
        currentUser.averageGrade = json["averageGradePoint"].float
        currentUser.majorCredit = json["totalCreditMajor"].float
        currentUser.majorGrade = json["averageGradePointMajor"].float
        // FIXME: Do not forget to save context
    }
    
}
