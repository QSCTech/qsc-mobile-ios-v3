//
//  MobileManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-29.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation

/// The mobile manager for JWBInfoSys. This class deals with login validation, data refresh and a variety of methods to filter data. Singleton pattern is used here.
public class MobileManager: NSObject {
    
    public static let sharedInstance = MobileManager()
    
    private var apiSession: APISession!
    
    /**
     Validate an account of JWBInfoSys and add to account manager if valid. Notice to call this method before other requests.
     
     - parameter username: Username of the account.
     - parameter password: Password of the account.
     - parameter callback: A closure to be executed once login request has finished. The first parameter is whether the request is successful, and the second one is the description of error if failed.
     */
    public func loginValidate(username: String, password: String, callback: (Bool, String?) -> Void) {
        apiSession = APISession(username: username, password: password)
        apiSession.loginRequest { status, error in
            if status {
                AccountManager.sharedInstance.addAccountToJwbinfosys(username, password: password)
                callback(status, error)
            } else {
                callback(status, error)
            }
        }
    }
    
    /**
     Try to refresh data of calendar, courses, exams, scores and buses. This method would succeed or fail both gracefully.
     */
    public func refreshAll() {
        refreshCalendar({ _ in })
        refreshCourses({ _ in })
        refreshExams({ _ in })
        refreshScores({ _ in })
        refreshBuses({ _ in })
    }
    
    /**
     Delete and retrive course data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshCourses(callback: (Bool) -> Void) {
        let dataManager = CoreDataManager.sharedInstance
        dataManager.deleteCourses()
        apiSession.courseRequest { json, error in
            if let json = json {
                dataManager.createCourses(json)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    /**
     Delete and retrive exam data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshExams(callback: (Bool) -> Void) {
        let dataManager = CoreDataManager.sharedInstance
        dataManager.deleteExams()
        apiSession.examRequest { json, error in
            if let json = json {
                dataManager.createExams(json)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    /**
     Delete and retrive score data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshScores(callback: (Bool) -> Void) {
        let dataManager = CoreDataManager.sharedInstance
        dataManager.deleteScores()
        apiSession.scoreRequest { json, error in
            if let json = json {
                dataManager.createSemesterScores(json)
                callback(true)
            } else {
                callback(false)
            }
        }
        apiSession.statisticsRequest { json, error in
            if let json = json {
                dataManager.createStatistics(json)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    /**
     Delete and retrive calendar data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshCalendar(callback: (Bool) -> Void) {
        let dataManager = CoreDataManager.sharedInstance
        dataManager.deleteCalendar()
        apiSession.calendarRequest { json, error in
            if let json = json {
                dataManager.createCalendar(json)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    /**
     Delete and retrive bus data from API.
     
     - parameter callback: A closure to be executed once the request has finished. The parameter is whether data has been refreshed successfully.
     */
    public func refreshBuses(callback: (Bool) -> Void) {
        let dataManager = CoreDataManager.sharedInstance
        dataManager.deleteBuses()
        apiSession.busRequest { json, error in
            if let json = json {
                dataManager.createBuses(json)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
}
