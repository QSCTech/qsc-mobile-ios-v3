//
//  NoticeManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-11.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit
import SwiftyJSON

public class NoticeManager: NSObject {
    
    public static let sharedInstance = NoticeManager()
    
    private let noticeAPI = NoticeAPI.sharedInstance
    
    private func eventFromJSON(json: JSON) -> NoticeEvent {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 28800)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return NoticeEvent(
            id: json["event"]["id"].stringValue,
            name: json["event"]["name"].stringValue,
            place: json["event"]["place"].stringValue,
            summary: json["event"]["summary"].stringValue,
            start: formatter.dateFromString(json["event"]["start_time"].stringValue)!,
            end: formatter.dateFromString(json["event"]["end_time"].stringValue)!,
            categoryId: json["category"]["id"].stringValue,
            categoryName: json["category"]["name"].stringValue,
            sponsorId: json["category"]["id"].stringValue,
            sponsorName: json["sponsor"]["showname"].stringValue,
            sponsorLogoURL: NSURL(string: json["sponsor"]["logo"].stringValue)!,
            sponsorLogo: nil,
            bonus: nil,
            content: nil,
            poster: nil
        )
    }
    
    public func allEventsWithPage(page: Int, callback: ([NoticeEvent]?, String?) -> Void) {
        noticeAPI.getAllEventsWithPage(page) { json, error in
            guard let json = json else {
                callback(nil, error)
                return
            }
            var array = [NoticeEvent]()
            for (_, json) in json {
                array.append(self.eventFromJSON(json))
            }
            callback(array, nil)
        }
    }
    
    public func updateSpnsorImageWithEvent(var event: NoticeEvent, callback: (NoticeEvent) -> Void) {
        noticeAPI.downloadImage(event.sponsorLogoURL) { image in
            event.sponsorLogo = image
            callback(event)
        }
    }
    
    public func updateDetailWithEvent(var event: NoticeEvent, callback: (NoticeEvent?, String?) -> Void) {
        noticeAPI.getEventDetailWithId(event.id) { json, error in
            guard let json = json else {
                callback(nil, error)
                return
            }
            var bonus = ""
            if json["event"]["jishikaoping"].stringValue != "0" {
                bonus += "综素加分 \(json["event"]["jishikaoping"].stringValue)  "
            }
            if json["event"]["dierketang"].stringValue != "0" {
                bonus += "二课加分 \(json["event"]["dierketang"].stringValue)"
            }
            event.bonus = bonus
            event.content = json["event"]["description"].stringValue
            let url = json["cover"]["filename"].stringValue
            guard !url.hasSuffix("default.jpg") else {
                callback(event, nil)
                return
            }
            self.noticeAPI.downloadImage(NSURL(string: url)!) { image in
                event.poster = image
                callback(event, nil)
            }
        }
    }
    
}
