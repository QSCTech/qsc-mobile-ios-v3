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
import SwiftyJSON
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

let AppKey = "aq86L/EUgOPxD7ZJzr3rK4zBRyo8oVzF"

let MobileAPIURL   = "https://m.zjuqsc.com/api/v3/s1"
let NoticeURL      = "https://notice.zjuqsc.com"
public let BoxURL  = "https://box.zjuqsc.com"
public let TideURL = "https://tide.zjuqsc.com/wp/"

public let AppGroupIdentifier = "group.QSCMobile"
public let QSCMobileKitIdentifier = "com.myqsc.iQSC.MobileKit"

public class QSCColor {
    public static let theme = UIColor(red: 0.523, green: 0.825, blue: 0.896, alpha: 1.0) // #85D3E5
    public static let dark = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0) // #4A4A4A
    public static let detailText = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1.0) // #8E8E93
    
    public static let course = UIColor(red: 0.290, green: 0.565, blue: 0.886, alpha: 1.0) // #4A90E2
    public static let exam = UIColor(red: 0.878, green: 0.298, blue: 0.518, alpha: 1.0) // #E04C84
    public static let homework = UIColor(red: 0.494, green: 0.826, blue: 0.130, alpha: 1.0) // #7ED321
    public static let activity = UIColor(red: 1.000, green: 0.820, blue: 0.000, alpha: 1.0) // #FFD100
    public static let actividad = UIColor(red: 0.722, green: 0.592, blue: 0.0, alpha: 1.0) // #B89700
    public static let todo = UIColor(red: 0.627, green: 0.420, blue: 0.745, alpha: 1.0) // #A06BBE
    public static let bus = UIColor(red: 0.451, green: 0.804, blue: 0.122, alpha: 1.0) // #73CD1F
    public static let autobús = UIColor(red: 0.039, green: 0.733, blue: 0.27, alpha: 1.0) // #0ABB07
    
    public static let ringGray = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.6)
    public static let darkGray = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
    
    public static func category(_ cat: Event.Category) -> UIColor {
        switch cat {
        case .course, .lesson:
            return course
        case .exam, .quiz:
            return exam
        case .activity:
            return activity
        case .todo:
            return todo
        case .bus:
            return bus
        }
    }
    
    public static func categoría(_ cat: Event.Category) -> UIColor {
        switch cat {
        case .activity:
            return actividad
        case .bus:
            return autobús
        default:
            return category(cat)
        }
    }
    
}

public let QSCVersion: String = {
    let info = Bundle.main.infoDictionary!
    return "Version \(info["CFBundleShortVersionString"]!) (Build \(info["CFBundleVersion"]!))"
}()

public struct Event {
    public enum Duration: Int, Hashable {
        case allDay = 0, partialTime
    }
    public enum Category: Int, Hashable {
        case course = 0, exam, lesson, quiz, activity, todo, bus
        
        public var name: String {
            switch self {
            case .course, .lesson:
                return "课程"
            case .exam, .quiz:
                return "考试"
            case .activity:
                return "活动"
            case .todo:
                return "待办"
            case .bus:
                return "校车"
            }
        }
    }
    public let duration: Duration
    public let category: Category
    public let tags: [String]
    public let name: String
    public let time: String
    public let place: String
    public let start: Date
    public let end: Date
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
public func eventsForDate(_ date: Date) -> [Event] {
    if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
        return EventManager.sharedInstance.customEventsForDate(date)
    } else {
        return MobileManager.sharedInstance.eventsForDate(date)
    }
}

public func delay(_ sec: Double, block: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + sec, execute: block)
}

/**
 Return an Alamofire manager with specific timeout interval. Remember to store it as property to prevent being freed.
 
 - parameter timeoutInterval: Timeout interval in seconds.
 
 - returns: The Alamofire manager.
 */
func alamofireManager(timeoutInterval: Double) -> Alamofire.SessionManager {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForResource = timeoutInterval
    return Alamofire.SessionManager(configuration: configuration)
}

extension Notification.Name {
    
    public static let refreshCompleted = Notification.Name("RefreshCompleted")
    public static let refreshError     = Notification.Name("RefreshError")
    public static let eventsModified   = Notification.Name("EventsModified")
    
}

public enum LoginMethod: String {
    case Jwb = "jwb"
    case ZJU_passport = "zju_passport"
}

private func parse(_ data: String) -> String? {
    let pattern = "ASP.NET_SessionId=(\\S*);"
    let regex = try! NSRegularExpression(pattern: pattern, options:[])
    let matches = regex.matches(in: data, options: [], range: NSRange(data.startIndex...,in: data))
    guard !matches.isEmpty else { return nil }
    var subStr = [String]()
    for match in matches {
        subStr.append((data as NSString).substring(with: match.range))
    }
    let str:String = subStr.first!
    let index = str.index(after: str.firstIndex(of: "=") ?? str.startIndex)
    let finalIndex = str.index(before: str.endIndex)
    return String(str[index..<finalIndex])
}

public func getCookie(username: String, password: String, method: LoginMethod) -> [HTTPCookiePropertyKey:Any]? {
    let urlForZjuam = "https://m.zjuqsc.com/api/v2/jw/validate?stuid=\(username)&pwd=\(password)&type=\(method.rawValue)&from=qsc_mobile_android"
    let url = NSURL(string: urlForZjuam)!
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "GET"
    var response:URLResponse?
    var props = Dictionary<HTTPCookiePropertyKey, Any>()
    do {
        let received:NSData? = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData
        if let datastring = NSString(data:received! as Data, encoding: String.Encoding.utf8.rawValue) {
            props[HTTPCookiePropertyKey.name] = "ASP.NET_SessionId"
            props[HTTPCookiePropertyKey.path] = "/"
            props[HTTPCookiePropertyKey.domain] = "jwbinfosys.zju.edu.cn"
            guard let cookieValue = parse(datastring as String) else { return nil }
            props[HTTPCookiePropertyKey.value] = cookieValue
            return props
        } else {
            return nil
        }
    } catch let error as NSError{
        print(error.description)
        return nil
    }
}

func MD5(string: String) -> Data {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: length)

    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)
                CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }
            return 0
        }
    }
    return digestData
}
