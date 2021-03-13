//
//  SimpleEvents.swift
//  QSCWidgetExtension
//
//  Created by Apple on 2021/3/12.
//  Copyright © 2021 QSC Tech. All rights reserved.
//

import Foundation
import QSCMobileKit

let startTime1 = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
let endTime1 = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

let time1 = startTime1.stringOfDatetime + "-" + endTime1.stringOfDatetime
let name1 = "沟通技巧"
let place1 = "玉泉曹光彪西楼-104（录播）"
let simpleEvent1 = WidgetEvent(duration: Event.Duration.allDay, category: Event.Category.course, tags: [], name: name1, time: time1, place: place1, start: startTime1, end: endTime1)

let startTime2 = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
let endTime2 = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
let time2 = startTime2.stringOfDatetime + "-" + endTime2.stringOfDatetime
let name2 = "面向对象程序设计"
let place2 = "紫金港西1-102（录播）"
let simpleEvent2 = WidgetEvent(duration: Event.Duration.allDay, category: Event.Category.course, tags: [], name: name2, time: time2, place: place2, start: startTime2, end: endTime2)

let startTime3 = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
let endTime3 = Calendar.current.date(byAdding: .hour, value: 5, to: Date())!
let time3 = startTime3.stringOfDatetime + "-" + endTime3.stringOfDatetime
let name3 = "概率论与数理统计"
let place3 = "紫金港西2-202（录播研）#37"
let simpleEvent3 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name3, time: time3, place: place3, start: startTime3, end: endTime3)

let startTime4 = Calendar.current.date(byAdding: .day, value: 1, to: startTime1)!
let endTime4 = Calendar.current.date(byAdding: .day, value: 1, to: endTime1)!

let time4 = startTime1.stringOfDatetime + "-" + endTime1.stringOfDatetime
let name4 = "沟通技巧"
let place4 = "玉泉曹光彪西楼-104（录播）"
let simpleEvent4 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name4, time: time4, place: place4, start: startTime4, end: endTime4)

let startTime5 = Calendar.current.date(byAdding: .day, value: 1, to: startTime2)!
let endTime5 = Calendar.current.date(byAdding: .day, value: 1, to: endTime2)!
let time5 = startTime2.stringOfDatetime + "-" + endTime2.stringOfDatetime
let name5 = "面向对象程序设计"
let place5 = "紫金港西1-102（录播）"
let simpleEvent5 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name5, time: time5, place: place5, start: startTime5, end: endTime5)

let startTime6 = Calendar.current.date(byAdding: .day, value: 1, to: startTime3)!
let endTime6 = Calendar.current.date(byAdding: .day, value: 1, to: endTime3)!
let time6 = startTime3.stringOfDatetime + "-" + endTime3.stringOfDatetime
let name6 = "概率论与数理统计"
let place6 = "紫金港西2-202（录播研）#37"
let simpleEvent6 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name6, time: time6, place: place6, start: startTime6, end: endTime6)

let simpleEvents: [WidgetEvent] = []
let simpleTomorrowEvents: [WidgetEvent] = [simpleEvent4, simpleEvent5, simpleEvent6]
