//
//  MobileManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-29.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData

/// The mobile manager for JWBInfoSys. This class deals with login validation, data refresh and a variety of methods to filter data. Make sure current account exists or login validation is invoked before using instance methods. Singleton pattern is used here.
public class MobileManager: NSObject {
    
    /**
     Try to initialize manager with current account stored in keychain and login to get session ID.
     */
    private override init() {
        super.init()
        if let account = accountManager.currentAccountForJwbinfosys {
            changeUser(account)
        }
    }
    
    public static let sharedInstance = MobileManager()
    
    private let accountManager = AccountManager.sharedInstance
    private let calendarManager = CalendarManager.sharedInstance
    private let managedObjectContext = DataStore.managedObjectContext
    
    private var apiSession: APISession!
    private var dataStore: DataStore!
    
    // MARK: - Manage accounts
    
    /**
     Validate a newly added account of JWBInfoSys. If valid, it will be added to account manager as current account and created as a user entity.
     
     - parameter username: Username of the account.
     - parameter password: Password of the account.
     - parameter callback: A closure to be executed once login request has finished. The first parameter is whether the request is successful, and the second one is the description of error if failed.
     */
    public func loginValidate(username: String, _ password: String, callback: (Bool, String?) -> Void) {
        let apiSession = APISession(username: username, password: password)
        apiSession.loginRequest { status, error in
            if status {
                let user = User(context: self.managedObjectContext)
                user.sid = username
                try! self.managedObjectContext.save()
                self.accountManager.addAccountToJwbinfosys(username, password)
                self.apiSession = apiSession
                self.dataStore = DataStore(username: username)
                self.refreshAll {}
                callback(status, error)
            } else {
                callback(status, error)
            }
        }
    }
    
    /**
     Change current account to already existed one and then refresh data.
     
     - parameter username: Username of the account.
     */
    public func changeUser(username: String) {
        apiSession = APISession(username: username, password: accountManager.passwordForJwbinfosys(username)!)
        apiSession.loginRequest { _ in }
        dataStore = DataStore(username: username)
    }
    
    /**
     Delete an account and clear its data from CoreData. If current account is deleted, it will be reset to another account.
     
     - parameter username: Username of the account
     */
    public func deleteUser(username: String) {
        accountManager.removeAccountFromJwbinfosys(username)
        let anotherDataSource = DataStore(username: username)
        anotherDataSource.deleteCourses()
        anotherDataSource.deleteExams()
        anotherDataSource.deleteScores()
        anotherDataSource.deleteUser()
        if let account = accountManager.currentAccountForJwbinfosys {
            changeUser(account)
        } else {
            dataStore = nil
            apiSession = nil
        }
    }
    
    // MARK: - Retrieve events
    
    /**
     Retrieve an array of courses on the specified date. Holidays and adjustments have been considered already.
    
     - returns: An array of type `Event` sorted by starting time.
     */
    public func coursesForDate(var date: NSDate) -> [Event] {
        if calendarManager.holidayForDate(date) != nil {
            return []
        }
        if let adjustment = calendarManager.adjustmentForDate(date) {
            date = adjustment.toDate
        }
        
        let year = calendarManager.yearForDate(date)
        let semester = calendarManager.semesterForDate(date)
        let weekOrdinal = calendarManager.weekOrdinalForDate(date)
        let calendar = NSCalendar.currentCalendar()
        let weekday = calendar.component(.Weekday, fromDate: date)
        let todayComponents = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        let courses = dataStore.getCourses(year: year, semester: semester)
        var array = [Event]()
        for course in courses {
            for timePlace in course.timePlaces! {
                let timePlace = timePlace as! TimePlace
                if timePlace.weekday == weekday && timePlace.week!.matchesWeekOrdinal(weekOrdinal) {
                    let startComponents = timePlace.periods!.startTimeForPeriods
                    todayComponents.hour = startComponents.hour
                    todayComponents.minute = startComponents.minute
                    let start = calendar.dateFromComponents(todayComponents)!
                    
                    let endComponents = timePlace.periods!.endTimeForPeriods
                    todayComponents.hour = endComponents.hour
                    todayComponents.minute = endComponents.minute
                    let end = calendar.dateFromComponents(todayComponents)!
                    
                    let event = Event(type: .PartialTime, category: .Course, tags: [], name: course.name!, time: timePlace.time!, place: timePlace.place!, start: start, end: end, object: course)
                    array.append(event)
                }
            }
        }
        return array.sort { $0.start <= $1.start }
    }
    
    /**
     Retrieve an array of exams on the specified date.
     
     - returns: An array of type `Event` sorted by starting time.
     */
    public func examsForDate(date: NSDate) -> [Event] {
        let year = calendarManager.yearForDate(date)
        let semester = calendarManager.semesterForDate(date)
        let calendar = NSCalendar.currentCalendar()
        let todayComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        let today = calendar.dateFromComponents(todayComponents)!
        let dayTimeInterval = NSTimeInterval(86400)
        let tomorrow = today.dateByAddingTimeInterval(dayTimeInterval)
        
        let exams = dataStore.getExams(year: year, semester: semester)
        var array = [Event]()
        for exam in exams {
            if let startTime = exam.startTime, endTime = exam.endTime {
                if !(exam.endTime! < today || exam.startTime! > tomorrow) {
                    let event = Event(type: .PartialTime, category: .Exam, tags: [], name: exam.name!, time: exam.time!, place: exam.place!, start: startTime, end: endTime, object: exam)
                    array.append(event)
                }
            }
        }
        return array.sort { $0.start <= $1.start }
    }
    
    // MARK: - Refresh data
    
    /**
     Try to refresh data of calendar, courses, exams, scores and buses. This method would succeed or fail both silently.
    
     - parameter callback: A closure to be executed once the request has finished.
     */
    public func refreshAll(callback: () -> Void) {
        let group = dispatch_group_create()
        for _ in 0..<5 {
            dispatch_group_enter(group)
        }
        refreshCalendar { _ in dispatch_group_leave(group) }
        refreshCourses { _ in dispatch_group_leave(group) }
        refreshExams { _ in dispatch_group_leave(group) }
        refreshScores { _ in dispatch_group_leave(group) }
        refreshBuses { _ in dispatch_group_leave(group) }
        dispatch_group_notify(group, dispatch_get_main_queue(), callback)
    }
    
    /**
     Delete and retrieve course data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshCourses(callback: (Bool, String?) -> Void) {
        apiSession.courseRequest { json, error in
            if let json = json {
                self.dataStore.deleteCourses()
                self.dataStore.createCourses(json)
                callback(true, error)
            } else {
                callback(false, error)
            }
        }
    }
    
    /**
     Delete and retrieve exam data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshExams(callback: (Bool, String?) -> Void) {
        apiSession.examRequest { json, error in
            if let json = json {
                self.dataStore.deleteExams()
                self.dataStore.createExams(json)
                callback(true, error)
            } else {
                callback(false, error)
            }
        }
    }
    
    /**
     Delete and retrieve score data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshScores(callback: (Bool, String?) -> Void) {
        apiSession.scoreRequest { json, error in
            if let json = json {
                self.dataStore.deleteScores()
                self.dataStore.createSemesterScores(json)
                self.apiSession.statisticsRequest { json, error in
                    if let json = json {
                        self.dataStore.createStatistics(json)
                        callback(true, error)
                    } else {
                        callback(false, error)
                    }
                }
            } else {
                callback(false, error)
            }
        }
    }
    
    /**
     Delete and retrieve calendar data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshCalendar(callback: (Bool, String?) -> Void) {
        apiSession.calendarRequest { json, error in
            if let json = json {
                self.dataStore.deleteCalendar()
                self.dataStore.createCalendar(json)
                callback(true, error)
            } else {
                callback(false, error)
            }
        }
    }
    
    /**
     Delete and retrieve bus data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshBuses(callback: (Bool, String?) -> Void) {
        apiSession.busRequest { json, error in
            if let json = json {
                self.dataStore.deleteBuses()
                self.dataStore.createBuses(json)
                callback(true, error)
            } else {
                callback(false, error)
            }
        }
    }
    
}