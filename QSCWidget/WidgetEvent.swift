//
//  WidgetEvent.swift
//  QSCWidgetExtension
//
//  Created by Apple on 2021/3/13.
//  Copyright © 2021 QSC Tech. All rights reserved.
//

import Foundation
import SwiftUI
import QSCMobileKit

struct WidgetEvent: Hashable{
    let duration: Event.Duration
    let category: Event.Category
    let tags: [String]
    let name: String
    let time: String
    let place: String
    let start: Date
    let end: Date
    
    var mainColor: Color {
        return Color(QSCColor.category(self.category))
    }
    
    init(event: Event) {
        self.duration = event.duration
        self.category = event.category
        self.tags = event.tags
        self.name = event.name
        self.time = event.time
        self.place = event.place
        self.start = event.start
        self.end = event.end
    }
    
    init(duration: Event.Duration, category: Event.Category, tags: [String], name: String, time: String, place: String, start: Date, end: Date) {
        self.duration = duration
        self.category = category
        self.tags = tags
        self.name = name
        self.time = time
        self.place = place
        self.start = start
        self.end = end
    }
    
    var toStartText: String {
        switch category {
        case .course, .lesson:
            return "距上课"
        case .exam, .quiz:
            return "距考试开始"
        case .activity:
            return "距活动开始"
        case .todo:
            return "距日程开始"
        case .bus:
            return "距校车出发"
        }
    }
    
    var toEndText: String {
        switch category {
        case .course, .lesson:
            return "距下课"
        case .exam, .quiz:
            return "距考试结束"
        case .activity:
            return "距活动结束"
        case .todo:
            return "距日程结束"
        case .bus:
            return "距校车到达"
        }
    }
    
    func timeString(_ date: Date) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            if self.category == .todo {
                formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
            }
            formatter.dateFormat = "hh:mm"
            return formatter
        }()
        
        return dateFormatter.string(from: date)
    }
}
