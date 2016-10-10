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
    
    private func eventFromJSON(_ json: JSON) -> NoticeEvent {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 28800)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return NoticeEvent(
            id: json["event"]["id"].stringValue,
            name: json["event"]["name"].stringValue,
            place: json["event"]["place"].stringValue,
            summary: json["event"]["summary"].stringValue,
            start: formatter.date(from: json["event"]["start_time"].stringValue)!,
            end: formatter.date(from: json["event"]["end_time"].stringValue)!,
            categoryId: json["category"]["id"].stringValue,
            categoryName: json["category"]["name"].stringValue,
            sponsorId: json["category"]["id"].stringValue,
            sponsorName: json["sponsor"]["showname"].stringValue,
            sponsorLogoURL: URL(string: json["sponsor"]["logo"].stringValue)!,
            bonus: nil,
            content: nil,
            posterURL: nil
        )
    }
    
    public func allEventsWithPage(_ page: Int, callback: @escaping ([NoticeEvent]?, String?) -> Void) {
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
    
    public func updateDetailWithEvent(_ event: NoticeEvent, callback: @escaping (NoticeEvent?, String?) -> Void) {
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
            var event = event
            event.bonus = bonus
            event.content = json["event"]["description"].stringValue
            let url = json["cover"]["filename"].stringValue
            event.posterURL = URL(string: url)
            callback(event, nil)
        }
    }
    
}
