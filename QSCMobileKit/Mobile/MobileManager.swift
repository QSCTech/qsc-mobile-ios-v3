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
    public func loginValidate(_ username: String, _ password: String, callback: @escaping (Bool, String?) -> Void) {
        let apiSession = APISession(username: username, password: password)
        apiSession.loginRequest { success, error in
            if success {
                DataStore.createUser(username)
                self.accountManager.addAccountToJwbinfosys(username, password)
                self.apiSession = apiSession
                self.dataStore = DataStore(username: username)
                self.refreshAll({ _ in }, callback: {
                    callback(success, error)
                })
            } else {
                callback(success, error)
            }
        }
    }
    
    /**
     Change current account to already existed one and try to update sessions without refreshing its data.
     
     - parameter username: Username of the account.
     */
    public func changeUser(_ username: String) {
        accountManager.currentAccountForJwbinfosys = username
        apiSession = APISession(username: username, password: accountManager.passwordForJwbinfosys(username)!)
        apiSession.loginRequest { _ in }
        dataStore = DataStore(username: username)
    }
    
    /**
     Delete an account and clear its data from CoreData. If current account is deleted, it will be reset to the first one of the rest (or nil).
     
     - parameter username: Username of the account
     */
    public func deleteUser(_ username: String) {
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
    
    public func eventsForDate(_ date: Date) -> [Event] {
        return (coursesForDate(date) + examsForDate(date) + eventManager.customEventsForDate(date)).sorted { $0.start <= $1.start }
    }
    
    /**
     Retrieve an array of courses on the specified date. Holidays and adjustments have been considered already. Note that holidays is prior to adjustments.
    
     - returns: An array of type `Event` sorted by starting time.
     */
    public func coursesForDate(_ date: Date) -> [Event] {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
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
        let weekday = Calendar.current.component(.weekday, from: date)
        
        let courses = dataStore.getCourses(year: year, semester: semester)
        var array = [Event]()
        for course in courses {
            for timePlace in course.timePlaces! {
                let timePlace = timePlace as! TimePlace
                if timePlace.weekday!.intValue == weekday && timePlace.week!.matchesWeekOrdinal(weekOrdinal) {
                    let startComponents = timePlace.periods!.startTimeForPeriods
                    dateComponents.hour = startComponents.hour
                    dateComponents.minute = startComponents.minute
                    let start = Calendar.current.date(from: dateComponents)!
                    
                    let endComponents = timePlace.periods!.endTimeForPeriods
                    dateComponents.hour = endComponents.hour
                    dateComponents.minute = endComponents.minute
                    let end = Calendar.current.date(from: dateComponents)!
                    
                    let courseEvent = eventManager.courseEventForIdentifier(course.identifier!)!
                    let tags = courseEvent.tags?.components(separatedBy: ",") ?? []
                    
                    let event = Event(duration: .partialTime, category: .course, tags: tags, name: course.name!, time: timePlace.time!, place: timePlace.place!, start: start, end: end, object: course)
                    array.append(event)
                }
            }
        }
        return array.sorted { $0.start <= $1.start }
    }
    
    /**
     Retrieve an array of exams on the specified date.
     
     - returns: An array of type `Event` sorted by starting time.
     */
    public func examsForDate(_ date: Date) -> [Event] {
        let year = calendarManager.yearForDate(date)
        let semester = calendarManager.semesterForDate(date)
        
        let exams = dataStore.getExams(year: year, semester: semester)
        var array = [Event]()
        for exam in exams {
            if let startTime = exam.startTime, let endTime = exam.endTime {
                if exam.startTime! < date.tomorrow && exam.endTime! >= date.today  {
                    var place = exam.place!
                    if !exam.seat!.isEmpty {
                        place += " #" + exam.seat!
                    }
                    let event = Event(duration: .partialTime, category: .exam, tags: [], name: exam.name!, time: exam.time!, place: place, start: startTime, end: endTime, object: exam)
                    array.append(event)
                }
            }
        }
        return array.sorted { $0.start <= $1.start }
    }
    
    
    // MARK: - Retrieve managed objects
    
    /**
     Get the managed object triple of course, exam and score with the identifier.
     
     - parameter identifier: Whose first 22 characters are taken as the identifier prefix.
     
     - returns: The triple of course, exam and score.
     */
    public func objectTripleWithIdentifier(_ identifier: String) -> (Course?, Exam?, Score?) {
        let id = identifier.substring(to: identifier.index(identifier.startIndex, offsetBy: 22))
        return (dataStore.objectsWithIdentifier(id, entityName: "Course").first as? Course,
                dataStore.objectsWithIdentifier(id, entityName: "Exam").first as? Exam,
                dataStore.objectsWithIdentifier(id, entityName: "Score").first as? Score
        )
    }
    
    public func courseNameWithIdentifier(_ identifier: String) -> String {
        let course = objectTripleWithIdentifier(identifier).0
        return course?.name ?? ""
    }
    
    public var semesterScores: [SemesterScore] {
        return dataStore.semesterScores
    }
    
    /**
     Get all courses of the given semester.
     
     - parameter semester: A string representing the semester, e.g. 2015-2016-2.
     
     - returns: The array of courses sorted by identifier.
     */
    public func getCourses(_ semester: String) -> [Course] {
        let courses = dataStore.objectsWithIdentifier("(\(semester))", entityName: "Course") as! [Course]
        return courses.sorted { $0.identifier! <= $1.identifier! }
    }
    
    /**
     Get all exams of the given semester.
     
     - parameter semester: A string representing the semester, e.g. 2015-2016-2.
     
     - returns: The array of exams sorted by time.
     */
    public func getExams(_ semester: String) -> [Exam] {
        let exams = dataStore.objectsWithIdentifier("(\(semester))", entityName: "Exam") as! [Exam]
        return exams.sorted { $1.startTime == nil || ($0.startTime != nil && $0.startTime! <= $1.startTime!) }
    }
    
    /**
     Get all scores of the given semester.
     
     - parameter semester: A string representing the semester, e.g. 2015-2016-2.
     
     - returns: The array of scores sorted by grade.
     */
    public func getScores(_ semester: String) -> [Score] {
        let scores = dataStore.objectsWithIdentifier("(\(semester))", entityName: "Score") as! [Score]
        return scores.sorted {
            if $0.gradePoint == $1.gradePoint {
                if let left = Int($0.score!), let right = Int($1.score!) {
                    return left >= right
                } else {
                    return $0.score! >= $1.score!
                }
            } else {
                return $0.gradePoint! > $1.gradePoint!
            }
        }
    }
    
    public var statistics: Statistics? {
        return dataStore.statistics
    }
    
    public var overseaScore: OverseaScore? {
        return dataStore.overseaScore
    }
    
    /// All semesters in which the current user has studied, sorted in ascending order, e.g. ["2015-2016-1", "2015-2016-2"].
    public var allSemesters: [String] {
        return dataStore.allSemesters
    }
    
    
    // MARK: - Refresh data
    
    /**
     Try to refresh data of calendar, courses, exams, scores and buses.
     
     - parameter errorBlock: A closure to be executed if there is any error.
     - parameter callback:   A closure to be executed once the request has finished.
     */
    public func refreshAll(_ errorBlock: @escaping (Notification) -> Void, callback: @escaping () -> Void) {
        let observer = NotificationCenter.default.addObserver(forName: .refreshError, object: nil, queue: .main, using: errorBlock)
        // First refresh calendar to prevent multiple sessionFail retries at the same time
        refreshCalendar { success, error in
            if success {
                let group = DispatchGroup()
                for _ in 0..<4 {
                    group.enter()
                }
                let closure = { (success: Bool, error: String?) in
                    if !success && !error!.isEmpty {
                        NotificationCenter.default.post(Notification(name: .refreshError, object: nil, userInfo: ["error": error!]))
                    }
                    group.leave()
                }
                self.refreshCourses(closure)
                self.refreshExams(closure)
                self.refreshScores(closure)
                self.refreshBuses(closure)
                group.notify(queue: DispatchQueue.main) {
                    callback()
                    NotificationCenter.default.removeObserver(observer)
                    NotificationCenter.default.post(name: .refreshCompleted, object: nil)
                }
            } else {
                NotificationCenter.default.post(Notification(name: .refreshError, object: nil, userInfo: ["error": error!]))
                callback()
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    
    /**
     Delete and retrieve course data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshCourses(_ callback: @escaping (Bool, String?) -> Void) {
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
    public func refreshExams(_ callback: @escaping (Bool, String?) -> Void) {
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
    public func refreshScores(_ callback: @escaping (Bool, String?) -> Void) {
        apiSession.scoreRequest { json, error in
            if let json = json {
                self.dataStore.deleteScores()
                self.dataStore.createScores(json)
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
    public func refreshCalendar(_ callback: @escaping (Bool, String?) -> Void) {
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
    public func refreshBuses(_ callback: @escaping (Bool, String?) -> Void) {
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
    
    /**
     Remove Mobile.sqlite & Mobile.sqlite-{wal,shm} from disk. Note this method is **DANGEROUS** because the managed object context will be invalid at once.
     */
    public func dropSqlite() {
        DataStore.dropSqlite()
    }
    
    /// Total size of Mobile.sqlite & Mobile.sqlite-{wal,shm}.
    public var sizeOfSqlite: String {
        return DataStore.sizeOfSqlite
    }
    
}
