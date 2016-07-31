//
//  Common.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

let AppKey = "aq86L/EUgOPxD7ZJzr3rK4zBRyo8oVzF"

let MobileAPIURL = "https://m.zjuqsc.com/v3api/"
let NoticeURL    = "https://notice.zjuqsc.com"
let BoxURL       = "https://box.zjuqsc.com"

public let AppGroupIdentifier = "group.com.zjuqsc.QSCMobileV3"
public let QSCMobileKitIdentifier = "com.zjuqsc.QSCMobileV3.QSCMobileKit"

public class QSCColor {
    public static let theme = UIColor(red: 0.523, green: 0.825, blue: 0.896, alpha: 1.0) // #85D3E5
    public static let dark = UIColor(red: 0.467, green: 0.467, blue: 0.467, alpha: 1.0) // #777777
    public static let detailText = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1.0) // #8E8E93
    
    public static let course = UIColor(red: 0.290, green: 0.565, blue: 0.886, alpha: 1.0) // #4A90E2
    public static let exam = UIColor(red: 0.878, green: 0.298, blue: 0.518, alpha: 1.0) // #E04C84
    public static let homework = UIColor(red: 0.494, green: 0.826, blue: 0.130, alpha: 1.0) // #7ED321
    public static let activity = UIColor(red: 1.000, green: 0.820, blue: 0.000, alpha: 1.0) // #FFD100
    public static let todo = UIColor(red: 0.627, green: 0.420, blue: 0.745, alpha: 1.0) // #A06BBE
    
    public static func event(category: Event.Category) -> UIColor {
        switch category {
        case .Course, .Lesson:
            return course
        case .Exam, .Quiz:
            return exam
        case .Activity:
            return activity
        default:
            return todo
        }
    }
}

public let QSCVersion: String = {
    let info = NSBundle.mainBundle().infoDictionary!
    return "\(info["CFBundleShortVersionString"]!) (Build \(info["CFBundleVersion"]!))"
}()

public struct Event {
    public enum Duration: Int {
        case AllDay = 0, PartialTime
    }
    public enum Category: Int {
        case Course = 0, Exam, Lesson, Quiz, Activity, Todo
    }
    public let duration: Duration
    public let category: Category
    public let tags: [String]
    public let name: String
    public let time: String
    public let place: String
    public let start: NSDate
    public let end: NSDate
    public let object: NSManagedObject
}

/**
 Chinese names of four seasons, used to identify the semester of courses.
 */
enum CourseSemester: String {
    case Spring = "春"
    case Summer = "夏"
    case Autumn = "秋"
    case Winter = "冬"
}

/**
 Abbreviations for semesters, used in JSON of calendar and scores.
 */
public enum CalendarSemester: String {
    
    case SummerMini = "SM"
    case Autumn     = "Au"
    case Winter     = "Wi"
    case WinterMini = "WM"
    case Spring     = "Sp"
    case Summer     = "Su"
    case SummerTime = "ST"
    case Unknown    = "Unknown"
    
    /// Chinese name of semesters, used in JSON of courses and exams.
    public var name: String {
        switch self {
        case .SummerMini:
            return "暑假"
        case .Autumn:
            return "秋"
        case .Winter:
            return "冬"
        case .WinterMini:
            return "寒假"
        case .Spring:
            return "春"
        case .Summer:
            return "夏"
        case .SummerTime:
            return "暑短"
        default:
            return ""
        }
    }
    
}

/**
 A safe way to get events for the given date.
 
 - parameter date: The specific date.
 
 - returns: Return all events when logged in, otherwise just return custom events.
 */
public func eventsForDate(date: NSDate) -> [Event] {
    if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
        return EventManager.sharedInstance.customEventsForDate(date)
    } else {
        return MobileManager.sharedInstance.eventsForDate(date)
    }
}

public func delay(second: NSTimeInterval, block: dispatch_block_t) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(second * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}

/**
 Return an Alamofire manager with specific timeout interval. Remember to store it as property to prevent being freed.
 
 - parameter timeoutInterval: Timeout interval in seconds.
 
 - returns: The Alamofire manager.
 */
func alamofireManager(timeoutInterval timeoutInterval: Double) -> Alamofire.Manager {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.timeoutIntervalForResource = timeoutInterval
    return Alamofire.Manager(configuration: configuration)
}
