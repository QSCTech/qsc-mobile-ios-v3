//
//  String+QSCMobileKit.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

extension String {
    
    /// Return a new string made by replacing all characters not allowed in a query URL component with percent encoded characters.
    public var percentEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    /// Return an attributed string with FontAwesome 16.0
    public var attributedWithFontAwesome: NSAttributedString {
        return NSAttributedString(string: self, attributes: [NSFontAttributeName: UIFont(name: "FontAwesome", size: 16)!])
    }
    
    public var attributedWithHelveticaNeue: NSAttributedString {
        return NSAttributedString(string: self, attributes: [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 16)!])
    }
    
    // TODO: Supplement the rule
    public var isValidSid: Bool {
        return characters.count == 10 || characters.count == 8
    }
    
    var startTimeForPeriods: DateComponents {
        var time = DateComponents()
        if self.characters.count == 0 {
            return time
        }
        switch characters.first! {
        case "1":
            time.hour = 8
            time.minute = 0
        case "2":
            time.hour = 8
            time.minute = 50
        case "3":
            time.hour = 9
            time.minute = 50
        case "4":
            time.hour = 10
            time.minute = 40
        case "5":
            time.hour = 11
            time.minute = 30
        case "6":
            time.hour = 13
            time.minute = 15
        case "7":
            time.hour = 14
            time.minute = 5
        case "8":
            time.hour = 14
            time.minute = 55
        case "9":
            time.hour = 15
            time.minute = 55
        case "a":
            time.hour = 16
            time.minute = 45
        case "b":
            time.hour = 18
            time.minute = 30
        case "c":
            time.hour = 19
            time.minute = 20
        case "d":
            time.hour = 20
            time.minute = 10
        default:
            break
        }
        return time
    }
    
    var endTimeForPeriods: DateComponents {
        var time = DateComponents()
        if characters.count == 0 {
            return time
        }
        switch characters.last! {
        case "1":
            time.hour = 8
            time.minute = 45
        case "2":
            time.hour = 9
            time.minute = 35
        case "3":
            time.hour = 10
            time.minute = 35
        case "4":
            time.hour = 11
            time.minute = 25
        case "5":
            time.hour = 12
            time.minute = 15
        case "6":
            time.hour = 14
            time.minute = 0
        case "7":
            time.hour = 14
            time.minute = 50
        case "8":
            time.hour = 15
            time.minute = 40
        case "9":
            time.hour = 16
            time.minute = 40
        case "a":
            time.hour = 17
            time.minute = 30
        case "b":
            time.hour = 19
            time.minute = 15
        case "c":
            time.hour = 20
            time.minute = 5
        case "d":
            time.hour = 20
            time.minute = 55
        default:
            break
        }
        return time
    }
    
    /**
     Judge if the specified Chinese characters includes the specified `CalendarSemester`. Note currently mini semesters have NOT been taken into account.
     
     - parameter semester: One of `CalendarSemester`.
     
     - returns: Whether it includes.
     */
    public func includesSemester(_ semester: CalendarSemester) -> Bool {
        switch semester {
        case .Autumn:
            return contains("秋")
        case .Winter:
            return contains("冬")
        case .Spring:
            return contains("春")
        case .Summer:
            return contains("夏")
        default:
            return false
        }
    }
    
    /**
     Judge if a string of odd/even week matches the specified week ordinal.
     
     - parameter weekOrdinal: An integer representing the week ordinal.
     
     - returns: Whether it matches.
     */
    func matchesWeekOrdinal(_ weekOrdinal: Int) -> Bool {
        switch self {
        case "每周":
            return true
        case "单":
            return weekOrdinal % 2 == 1
        case "双":
            return weekOrdinal % 2 == 0
        default:
            return false
        }
    }
    
    /// For example, "2016-2017-1" -> "2016-2017 秋冬".
    public var fullNameForSemester: String {
        return substring(to: index(endIndex, offsetBy: -2)) + (hasSuffix("1") ? " 秋冬" : " 春夏")
    }
    
    /// Same as `String#chomp` in Ruby.
    func chomp(_ separator: String) -> String {
        if hasSuffix(separator) {
            return substring(to: index(before: endIndex))
        } else {
            return self
        }
    }
    
}

public func += (left: inout String!, right: String) {
    left = (left ?? "") + right
}
