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
     Validate a newly added account of JWBInfoSys. If valid, it will be added to account manager as current account and created as a user entity. Usually you want to call `refreshAll` in the callback function.
     
     - parameter username: Username of the account.
     - parameter password: Password of the account.
     - parameter callback: A closure to be executed once login request has finished. The argument will be nil if login succeeds, otherwise it will be the description of error.
     */
    public func loginValidate(_ username: String, _ password: String, callback: @escaping (String?) -> Void) {
        let apiSession = APISession(username: username, password: password)
        apiSession.loginRequest { error in
            if let error = error {
                callback(error)
            } else {
                DataStore.createUser(username)
                self.accountManager.addAccountToJwbinfosys(username, password)
                self.apiSession = apiSession
                self.dataStore = DataStore(username: username)
                callback(nil)
            }
        }
    }
    
    /**
     Change current account to already existed one and try to update sessions without refreshing its data. Usually you want to call `refreshAll` afterwards.
     
     - parameter username: Username of the account.
     */
    public func changeUser(_ username: String) {
        guard let password = accountManager.passwordForJwbinfosys(username) else {
            deleteUser(username)
            return
        }
        accountManager.currentAccountForJwbinfosys = username
        apiSession = APISession(username: username, password: password)
        apiSession.loginRequest { _ in }
        dataStore = DataStore(username: username)
        NotificationCenter.default.post(name: .eventsModified, object: nil)
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
                var qualified = false
                if let specials = calendarManager.specialsForCourse(course: course, date: date) {
                    for special in specials {
                        if Calendar.current.isDate(date, inSameDayAs: special.date!) && special.weekly! == timePlace.week! {
                            qualified = true
                        }
                    }
                } else if timePlace.weekday!.intValue == weekday && timePlace.week!.matchesWeekOrdinal(weekOrdinal) {
                    qualified = true
                }
                if qualified {
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
    
    func filteredExams(_ date: Date, type: Int) -> [Event] {
        let year = calendarManager.yearForDate(date)
        let semester = calendarManager.semesterForDate(date)
        
        let upperBound: Date
        let lowerBound: Date
        if type == 0 {
            upperBound = date.tomorrow
            lowerBound = date.today
        } else {
            upperBound = date.tomorrow.addingTimeInterval(2592000) // 30 days
            lowerBound = date.tomorrow
        }
        
        let exams = dataStore.getExams(year: year, semester: semester)
        var array = [Event]()
        for exam in exams {
            if let startTime = exam.startTime, let endTime = exam.endTime, exam.startTime! < upperBound && exam.endTime! >= lowerBound  {
                let place = exam.place! + (exam.seat!.isEmpty ? "" : " #" + exam.seat!)
                let event = Event(duration: .partialTime, category: .exam, tags: [], name: exam.name!, time: exam.time!, place: place, start: startTime, end: endTime, object: exam)
                array.append(event)
            }
        }
        return array.sorted { $0.start <= $1.start }
    }
    
    public func examsForDate(_ date: Date) -> [Event] {
        return filteredExams(date, type: 0)
    }
    
    public var comingExams: [Event] {
        return filteredExams(Date(), type: 1)
    }
    
    
    // MARK: - Retrieve managed objects
    
    public func prefixForIdentifier(_ identifier: String) -> String {
        return identifier.count < 22 ? identifier : String(identifier[..<identifier.index(identifier.startIndex, offsetBy: 22)])
    }
    
    public func courseObjectsWithIdentifier(_ identifier: String) -> [Course] {
        return dataStore.objectsWithIdentifier(prefixForIdentifier(identifier), entityName: "Course") as! [Course]
    }
    
    public func courseNameWithIdentifier(_ identifier: String) -> String {
        let course = courseObjectsWithIdentifier(identifier).first
        return course?.name ?? ""
    }
    
    public func courseCreditWithIdentifier(_ identifier: String) -> Float {
        if let course = courseObjectsWithIdentifier(identifier).first, let credit = course.credit?.floatValue, credit > 0 {
            return credit
        } else if let exam = examObjectsWithIdentifier(identifier).first, let credit = exam.credit?.floatValue, credit > 0 {
            return credit
        } else if let score = scoreObjectsWithIdentifier(identifier).first, let credit = score.credit?.floatValue, credit > 0 {
            return credit
        } else {
            return 0
        }
    }
    
    public func examObjectsWithIdentifier(_ identifier: String) -> [Exam] {
        return dataStore.objectsWithIdentifier(prefixForIdentifier(identifier), entityName: "Exam") as! [Exam]
    }
    
    public func scoreObjectsWithIdentifier(_ identifier: String) -> [Score] {
        return dataStore.objectsWithIdentifier(prefixForIdentifier(identifier), entityName: "Score") as! [Score]
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
    
    public var calculatedGPA: Float {
        var grade = Float(0)
        for semesterScore in semesterScores {
            grade += semesterScore.averageGrade!.floatValue * semesterScore.totalCredit!.floatValue
        }
        grade /= statistics!.totalCredit!.floatValue
        return grade
    }
    
    public var totalCredit: Float {
        var credit = Float(0)
        for semesterScore in semesterScores {
            credit += semesterScore.totalCredit!.floatValue
        }
        return credit
    }
    
    /// All semesters in which the current user has studied, sorted in ascending order, e.g. ["2015-2016-1", "2015-2016-2"].
    public var allSemesters: [String] {
        let user = DataStore.entityForUser(accountManager.currentAccountForJwbinfosys!)!
        if let start = user.startSemester, let end = user.endSemester {
            var semesters = [start]
            var current = start
            while current != end {
                if current.hasSuffix("1") {
                    let index = current.index(before: current.endIndex)
                    current = current[..<index] + "2"
                } else {
                    let index = current.index(current.startIndex, offsetBy: 4)
                    let year = Int(current[..<index])!
                    current = "\(year + 1)-\(year + 2)-1"
                }
                if !getCourses(current).isEmpty {
                    semesters.append(current)
                }
            }
            return semesters
        } else {
            return []
        }
    }
    
    
    // MARK: - Refresh data
    
    /**
     Try to refresh data of calendar, courses, exams, scores and buses.
     
     - parameter callback:   A closure to be executed once the request has finished.
     */
    public func refreshAll(callback: @escaping () -> Void) {
        apiSession.resourceRequest { json, error in
            if let json = json {
                for response in json.arrayValue {
                    let data = response["data"]
                    guard data.exists() else { continue }
                    switch response["uuid"].stringValue {
                    case "courses":
                        self.dataStore.deleteCourses()
                        self.dataStore.createCourses(data)
                    case "exams":
                        self.dataStore.deleteExams()
                        self.dataStore.createExams(data)
                    case "grades":
                        if data["scoreObject"].dictionaryValue.isEmpty { continue }
                        self.dataStore.deleteScores()
                        self.dataStore.createScores(data)
                    case "statistics":
//                        if data["totalCredit"].numberValue == 0 { continue }
                        self.dataStore.deleteStatistics()
                        self.dataStore.createStatistics(data)
                    case "calendars":
                        self.dataStore.deleteCalendar()
                        self.dataStore.createCalendar(data)
                    case "buses":
                        self.dataStore.deleteBuses()
                        self.dataStore.createBuses(data)
                    default:
                        print("Unknown uuid in the response list: \(response["uuid"].stringValue)")
                    }
                    callback()
                    NotificationCenter.default.post(name: .refreshCompleted, object: nil)
                    NotificationCenter.default.post(name: .eventsModified, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .refreshError, object: nil, userInfo: ["error": error ?? ""])
                callback()
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
