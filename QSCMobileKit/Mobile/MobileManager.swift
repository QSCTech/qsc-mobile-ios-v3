//
//  MobileManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-29.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation

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
    private let eventManager = EventManager.sharedInstance
    
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
        apiSession.loginRequest { success, error in
            if success {
                DataStore.createUser(username)
                self.accountManager.addAccountToJwbinfosys(username, password)
                self.apiSession = apiSession
                self.dataStore = DataStore(username: username)
                self.refreshAll {
                    callback(success, error)
                }
            } else {
                callback(success, error)
            }
        }
    }
    
    /**
     Change current account to already existed one and try to update sessions without refreshing its data.
     
     - parameter username: Username of the account.
     */
    public func changeUser(username: String) {
        accountManager.currentAccountForJwbinfosys = username
        apiSession = APISession(username: username, password: accountManager.passwordForJwbinfosys(username)!)
        apiSession.loginRequest { _ in }
        dataStore = DataStore(username: username)
    }
    
    /**
     Delete an account and clear its data from CoreData. If current account is deleted, it will be reset to the first one of the rest (or nil).
     
     - parameter username: Username of the account
     */
    public func deleteUser(username: String) {
        accountManager.removeAccountFromJwbinfosys(username)
        let anotherDataSource = DataStore(username: username)
        anotherDataSource.deleteCourses()
        anotherDataSource.deleteExams()
        anotherDataSource.deleteScores()
        anotherDataSource.deleteStatistics()
        anotherDataSource.deleteUser()
        if let account = accountManager.currentAccountForJwbinfosys {
            changeUser(account)
        } else {
            dataStore = nil
            apiSession = nil
        }
    }
    
    // MARK: - Retrieve events
    
    public func eventsForDate(date: NSDate) -> [Event] {
        return (coursesForDate(date) + examsForDate(date) + customEventsForDate(date)).sort { $0.start <= $1.start }
    }
    
    /**
     Retrieve an array of courses on the specified date. Holidays and adjustments have been considered already. Note that holidays is prior to adjustments.
    
     - returns: An array of type `Event` sorted by starting time.
     */
    public func coursesForDate(date: NSDate) -> [Event] {
        if calendarManager.holidayForDate(date) != nil {
            return []
        }
        var date = date
        if let adjustment = calendarManager.adjustmentForDate(date) {
            date = adjustment.fromDate
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
                    
                    let courseEvent = eventManager.courseEventForIdentifier(course.identifier!)!
                    let tags = courseEvent.tags?.componentsSeparatedByString(",") ?? []
                    
                    let event = Event(duration: .PartialTime, category: .Course, tags: tags, name: course.name!, time: timePlace.time!, place: timePlace.place!, start: start, end: end, object: course)
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
        
        let exams = dataStore.getExams(year: year, semester: semester)
        var array = [Event]()
        for exam in exams {
            if let startTime = exam.startTime, endTime = exam.endTime {
                if exam.startTime! < date.tomorrow && exam.endTime! >= date.today  {
                    var place = exam.place!
                    if !exam.seat!.isEmpty {
                        place += " #" + exam.seat!
                    }
                    let event = Event(duration: .PartialTime, category: .Exam, tags: [], name: exam.name!, time: exam.time!, place: place, start: startTime, end: endTime, object: exam)
                    array.append(event)
                }
            }
        }
        return array.sort { $0.start <= $1.start }
    }
    
    public func customEventsForDate(date: NSDate) -> [Event] {
        let events = eventManager.customEventsForDate(date)
        return events.map { event in
            let duration = Event.Duration(rawValue: event.duration!.integerValue)!
            let category = Event.Category(rawValue: event.category!.integerValue)!
            let tags = event.tags!.isEmpty ? [] : event.tags!.componentsSeparatedByString(",")
            
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy年MM月dd日"
            var startTime = formatter.stringFromDate(event.start!)
            var endTime = formatter.stringFromDate(event.end!)
            let time: String
            if startTime == endTime {
                if event.duration! == Event.Duration.PartialTime.rawValue {
                    formatter.dateFormat = "HH:mm"
                    startTime += " " + formatter.stringFromDate(event.start!)
                    endTime = formatter.stringFromDate(event.end!)
                    time = startTime + "-" + endTime
                } else {
                    time = startTime
                }
            } else {
                time = startTime + " - " + endTime
            }
            
            return Event(duration: duration, category: category, tags: tags, name: event.name!, time: time, place: event.place!, start: event.start!, end: event.end!, object: event)
        }
    }
    
    
    // MARK: - Refresh data
    
    /**
     Try to refresh data of calendar, courses, exams, scores and buses. This method would succeed or fail both silently.
    
     - parameter callback: A closure to be executed once the request has finished.
     */
    public func refreshAll(callback: () -> Void) {
        // First refresh calendar to prevent multiple sessionFail retries at the same time
        refreshCalendar { success, error in
            if success {
                let group = dispatch_group_create()
                for _ in 0..<4 {
                    dispatch_group_enter(group)
                }
                self.refreshCourses { _ in dispatch_group_leave(group) }
                self.refreshExams { _ in dispatch_group_leave(group) }
                self.refreshScores { _ in dispatch_group_leave(group) }
                self.refreshBuses { _ in dispatch_group_leave(group) }
                dispatch_group_notify(group, dispatch_get_main_queue(), callback)
            }
        }
        // TODO: Send notifications if failed.
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
                        self.dataStore.deleteStatistics()
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
    
    // MARK: - Manage SQLite
    
    public func dropSqlite() {
        DataStore.dropSqlite()
    }
    
    public var sizeOfSqlite: String {
        return DataStore.sizeOfSqlite
    }
    
}
