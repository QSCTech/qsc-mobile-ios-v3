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

public let QSCVersion: String = {
    let info = NSBundle.mainBundle().infoDictionary!
    return "\(info["CFBundleShortVersionString"]!) (Build \(info["CFBundleVersion"]!))"
}()

public struct Event {
    public enum Type {
        case AllDay, PartialTime
    }
    public enum Category {
        case Course, Exam, Quiz, Custom
    }
    public let type: Type
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
    
    case SummerMini     = "SM"
    case Autumn         = "Au"
    case Winter         = "Wi"
    case WinterMini     = "WM"
    case Spring         = "Sp"
    case Summer         = "Su"
    case SummerVacation = "ST"
    case Unknown        = "Unknown"
    
    /// Chinese name of semesters, used in JSON of courses and exams.
    var name: String {
        switch self {
        case .SummerMini:
            return "夏短"
        case .Autumn:
            return "秋"
        case .Winter:
            return "冬"
        case .WinterMini:
            return "冬短"
        case .Spring:
            return "春"
        case .Summer:
            return "夏"
        case .SummerVacation:
            return "暑"
        default:
            return ""
        }
    }
    
}

public func delay(second: Double, block: dispatch_block_t) {
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
