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
    
    /**
      Create a course in managed object context.
     
     - parameter json: JSON of a course.
     */
    func createCourse(json: JSON) {
        let course = Course(context: managedObjectContext)
        // FIXME: set user
        
        course.code = json["code"].string
        course.name = json["name"].string
        course.teacher = json["teacher"].string
        course.semester = json["semester"].string
        course.determined = json["determined"].bool // FIXME
        course.identifier = json["hash"].string // Workaround
        course.year = json["year"].string
        
        let basicInfo = json["basicInfo"]
        course.credit = basicInfo["Credit"].float // FIXME
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
    
    func createExam(json: JSON) {
        let exam = Exam(context: managedObjectContext)
        // FIXME: Set user
        
        exam.credit = json["credit"].float // FIXME
        exam.identifier = json["identifier"].string
        exam.isRelearning = json["isRelearning"].bool // FIXME
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
    
    func createScore(json: JSON) {
        let score = Score(context: managedObjectContext)
        // FIXME: set user
        
        score.credit = json["credit"].float // FIXME
        score.identifier = json["identifier"].string
        score.makeup = json["makeup"].string
        score.name = json["name"].string
        score.gradePoint = (json["gradePoint"].string! as NSString).floatValue
        score.score = Int(json["score"].string!, radix:10)
    }
    
}
