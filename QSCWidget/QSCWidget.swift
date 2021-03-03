//
//  QSCWidget.swift
//  QSCWidget
//
//  Created by 高伟渊 on 2021/1/29.
//  Copyright © 2021 QSC Tech. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import QSCMobileKit
import CoreData

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
        switch self.category {
        case .activity:
            return Color(QSCColor.activity)
        case .bus:
            return Color(QSCColor.bus)
        case .course:
            return Color(QSCColor.course)
        case .exam:
            return Color(QSCColor.exam)
        case .todo:
            return Color(QSCColor.todo)
        default:
            return Color.black
        }
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
}

enum EntryStyle {
    case detailed
    case concise
}

/**

 屏幕尺寸         - portrait                                小-systemSmall  中-systemMedium 大-systemLarge
 428x926 pt    (12 Pro Max)                        175x175 pt
 390x844 pt    (12/12 Pro) 2.16410             159x159 pt
 375x812 pt    (12 mini)                               153x153 pt
 414x896 pt    (XR/XsMax/11/11ProMax)   169x169 pt    360x169 pt    360x379 pt
 375x812 pt    (X/Xs/11 Pro)                       155x155 pt    329x155 pt    329x345 pt
 414x736 pt    (6p/6sp/7p)                          159x159 pt    348x159 pt    348x357 pt
 375x667 pt    (6/6s/7/8)                             148x148 pt    321x148 pt    321x324 pt
 320x568 pt    (5/5s/SE)                              141x141 pt    292x141 pt    292x311 pt
 
 Screen size (portrait)    Small widget    Medium widget    Large widget
 414x896 pt    169x169 pt    360x169 pt    360x376 pt
 375x812 pt    155x155 pt    329x155 pt    329x345 pt
 414x736 pt    159x159 pt    348x159 pt    348x357 pt
 375x667 pt    148x148 pt    322x148 pt    322x324 pt
 320x568 pt    141x141 pt    291x141 pt    291x299 pt
*/

let widgetTargetWidth: CGFloat = 159
let iPhoneHeight = UIScreen.main.bounds.size.height

func RatioLen(_ length: CGFloat) -> CGFloat {
    if iPhoneHeight == 926 {
        return length * 175 / widgetTargetWidth
    } else if iPhoneHeight == 844 {
        return length * 159 / widgetTargetWidth
    } else if iPhoneHeight == 896 {
        return length * 169 / widgetTargetWidth
    } else if iPhoneHeight == 812 {
        return length * 155 / widgetTargetWidth
    } else if iPhoneHeight == 736 {
        return length * 159 / widgetTargetWidth
    } else if iPhoneHeight == 667 {
        return length * 148 / widgetTargetWidth
    } else if iPhoneHeight == 568 {
        return length * 141 / widgetTargetWidth
    } else {
        return length * iPhoneHeight / 844
    }
}

let startTime1 = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
let endTime1 = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

let time1 = startTime1.stringOfDatetime + "-" + endTime1.stringOfDatetime
let name1 = "沟通技巧"
let place1 = "紫金港西2-103（录播)"
let simpleEvent1 = WidgetEvent(duration: Event.Duration.allDay, category: Event.Category.bus, tags: [], name: name1, time: time1, place: place1, start: startTime1, end: endTime1)

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

let simpleEvents: [WidgetEvent] = []

let simpleConfig = ConfigurationIntent()

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> QSCWidgetEntry {
        QSCWidgetEntry(date: Date(), configuration: ConfigurationIntent(), events: simpleEvents, style: .concise)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (QSCWidgetEntry) -> ()) {
        let entry = QSCWidgetEntry(date: Date(), configuration: configuration, events: simpleEvents, style: .concise)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [QSCWidgetEntry] = []
        let events = eventsForDate(Date())
        var currentDate = Date() - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60) + TimeInterval(1)
        let oneMinute: TimeInterval = 60
        
        let upcomingEvents = events.filter { $0.end > currentDate }
        var upcomingWidgetEvents = upcomingEvents.map{ return WidgetEvent(event: $0) }
        let firstEndEvent: WidgetEvent? = upcomingWidgetEvents.sorted { $0.end <= $1.end }.first
        
        var style: EntryStyle
        switch configuration.style {
        case .concise:
            style = .concise
        default:
            style = .detailed
        }
        
        for _ in 0 ..< 60 {
            upcomingWidgetEvents = upcomingWidgetEvents.filter{ $0.end > currentDate }
            let entry = QSCWidgetEntry(date: currentDate, configuration: configuration, events: upcomingWidgetEvents, style: style)
            entries.append(entry)
            currentDate += oneMinute
        }
        
        let reloadDate: Date
        if let firstEndEvent = firstEndEvent {
            reloadDate = min(firstEndEvent.end, currentDate - 20 * oneMinute)
        } else {
            reloadDate = min(currentDate.tomorrow, currentDate - 20 * oneMinute)
        }
        
        let timeline = Timeline(entries: entries, policy: .after(reloadDate))
        completion(timeline)
    }
}

struct QSCWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    
    let events: [WidgetEvent]
    let style: EntryStyle
}

struct QSCWidgetEntryView : View {
    var entry: Provider.Entry
    var firstEvent: WidgetEvent? {
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime })
    }
    var upcomingEvents: [WidgetEvent] {
        return Array(entry.events.prefix(3))
    }
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView(entry: entry)
        case .systemMedium:
            mediumWidgetView(entry: entry)
        case .systemLarge:
            largeWidgetView(entry: entry)
        @unknown default:
            NothingView()
        }
    }
}

@main
struct QSCWidget: Widget {
    let kind: String = "QSCWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QSCWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct QSCWidget_Previews: PreviewProvider {
    static var previews: some View {
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .detailed))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .detailed))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

struct smallWidgetView: View {
    var entry: Provider.Entry
    
    var firstEvent: WidgetEvent? {
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime }) != nil ? entry.events.first(where: { $0.duration == Event.Duration.partialTime }) :  entry.events.first(where: { $0.duration == Event.Duration.allDay })
    }
    
    var body: some View {
        if let firstEvent = firstEvent {
            HStack{
                switch entry.style {
                case .concise:
                        EventRingView(event: firstEvent, currentDate: entry.date, multiplier: 1)
                default:
                        FirstEventView(firstEvent: firstEvent, currentDate: entry.date)
                        Spacer(minLength: 0)
                }
            }
        } else {
            NothingView()
        }
    }
    
}

struct mediumWidgetView: View {
    let entry: Provider.Entry
    
    var firstEvent: WidgetEvent? {
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime }) != nil ? entry.events.first(where: { $0.duration == Event.Duration.partialTime }) :  entry.events.first(where: { $0.duration == Event.Duration.allDay })
    }
    
    var upcomingEvents: [WidgetEvent?] {
        var upcomingEvents: [WidgetEvent?] = Array(entry.events.prefix(3))
        for _ in upcomingEvents.endIndex ..< 3 {
            upcomingEvents.append(nil)
        }
        return upcomingEvents
    }
    
    var body: some View {
        if let firstEvent = firstEvent {
            HStack{
                switch entry.style {
                case .concise:
                    EventRingView(event: firstEvent, currentDate: entry.date, multiplier: 1)
                default:
                    FirstEventView(firstEvent: firstEvent, currentDate: entry.date)
                }
                Spacer(minLength: 0)
                EventsView(upcomingEvents: upcomingEvents)
            }
        } else {
            NothingView()
        }
    }
}

struct largeWidgetView: View {
    var entry: Provider.Entry
    
    var firstEvent: WidgetEvent? {
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime }) != nil ? entry.events.first(where: { $0.duration == Event.Duration.partialTime }) :  entry.events.first(where: { $0.duration == Event.Duration.allDay })
    }
    
    var body: some View {
        if let firstEvent = firstEvent {
            switch entry.style {
            case .concise:
                HStack{
                    EventRingView(event: firstEvent, currentDate: entry.date, multiplier: 2.4)
                }
            default:
                HStack{
                    FirstEventView(firstEvent: firstEvent, currentDate: entry.date)
                    Spacer(minLength: 0)
                }
            }
        } else {
            NothingView()
        }
    }
}

struct FirstEventView: View {
    let firstEvent: WidgetEvent
    let currentDate: Date
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading){
            Text(firstEvent.name)
                .font(.system(size: RatioLen(20), weight: .bold))
                .foregroundColor(firstEvent.mainColor)
                .lineLimit(1)
            Spacer()
            if currentDate < firstEvent.start {
                Text(firstEvent.toStartText)
                    .font(.system(size: RatioLen(12), weight: .light))
                    .foregroundColor(.gray)
                Text(firstEvent.start.timeIntervalSince(currentDate).timeDescription)
                    .font(.system(size: RatioLen(32), weight: .bold))
                    .foregroundColor(firstEvent.mainColor)
            } else {
                Text(firstEvent.toEndText)
                    .font(.system(size: RatioLen(12), weight: .light))
                    .foregroundColor(.gray)
                Text(firstEvent.end.timeIntervalSince(currentDate).timeDescription)
                    .font(.system(size: RatioLen(32), weight: .bold))
                    .foregroundColor(firstEvent.mainColor)
            }
            Spacer()
            HStack{
                Text("\u{F041}")
                    .font(.custom("FontAwesome", size: RatioLen(12)))
                Text(firstEvent.place)
                    .font(.system(size: RatioLen(12), weight: .light))
                    .lineLimit(1)
            }
            HStack{
                Text("\u{F017}")
                    .font(.custom("FontAwesome", size: RatioLen(12)))
                let timeString = firstEvent.duration == Event.Duration.partialTime ? firstEvent.start.stringOfTime + "-" + firstEvent.end.stringOfTime : "全天"
                Text(timeString)
                    .font(.system(size: RatioLen(12), weight: .light))
                    .lineLimit(1)
                    .padding(.leading, RatioLen(-2))
            }
            .padding(.leading, RatioLen(-2))
            .padding(.bottom, RatioLen(-2))
            
        }
        .frame(width: RatioLen(135), height: RatioLen(135), alignment: .leading)
        .padding(.leading, RatioLen(15))
        .padding(.bottom, RatioLen(3))
    }
}

struct RingProgressView: View {
    let event: WidgetEvent
    let currentDate: Date
    var width: CGFloat = RatioLen(80)
    var percent: CGFloat {
        if currentDate.tomorrow <= event.start {
            let days = Int(event.start.today.timeIntervalSince(currentDate.today) / 86400)
            return CGFloat(30 - days) / 30.0
        } else if currentDate < event.start {
            return CGFloat(currentDate.timeIntervalSince(currentDate.today)) / CGFloat(event.start.timeIntervalSince(currentDate.today))
        } else if currentDate <= event.end {
            return CGFloat(currentDate.timeIntervalSince(event.start)) / CGFloat(event.end.timeIntervalSince(event.start))
        } else {
            return 0
        }
    }
    var color1: Color
    var color2: Color
    
    var body: some View {
        let mutiplier = width / RatioLen(80)
        let progress = 1 - percent
        
        ZStack {
            Circle()
                .stroke(Color(QSCColor.gray),
                        style: StrokeStyle(lineWidth: RatioLen(5) * mutiplier))
                .frame(width: width, height: width)
            
            Circle()
                .trim(from: progress, to: 1)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: RatioLen(5) * mutiplier, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: RatioLen(1), y: 0, z: 0))
                .frame(width: width, height: width)
                .shadow(color: color1.opacity(0.1), radius: RatioLen(3), x: 0, y: RatioLen(3))
            VStack{
                if currentDate < event.start {
                    Text(event.toStartText)
                        .font(.system(size: RatioLen(9) * mutiplier, weight: .light))
                        .foregroundColor(.gray)
                    Text(event.start.timeIntervalSince(currentDate).timeDescription)
                        .font(.system(size: RatioLen(20) * mutiplier, weight: .bold))
                        .foregroundColor(event.mainColor)
                } else {
                    Text(event.toEndText)
                        .font(.system(size: RatioLen(9) * mutiplier, weight: .light))
                        .foregroundColor(.gray)
                    Text(event.end.timeIntervalSince(currentDate).timeDescription)
                        .font(.system(size: RatioLen(20) * mutiplier, weight: .bold))
                        .foregroundColor(event.mainColor)
                }
            }
        }
    }
}
struct EventCellView: View {
    let event: WidgetEvent?
    let cellHeight: CGFloat
    
    var body: some View {
        if let event = event {
            ZStack{
                RoundedRectangle(cornerRadius: RatioLen(12), style: .continuous)
                    .stroke(event.mainColor, lineWidth: RatioLen(1))
                HStack{
                    if event.duration == Event.Duration.partialTime {
                        VStack(alignment: .leading){
                            Text(event.start.stringOfTime)
                                .font(.system(size: RatioLen(10)))
                                .foregroundColor(.gray)
                            Text(event.end.stringOfTime)
                                .font(.system(size: RatioLen(10)))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, RatioLen(5.0))
                        .frame(width: RatioLen(40))
                    } else {
                        Text("全天")
                            .font(.system(size: RatioLen(10)))
                            .foregroundColor(.gray)
                            .padding(.vertical, RatioLen(5.0))
                            .frame(width: RatioLen(40))
                    }
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text(event.name)
                                .font(.system(size: RatioLen(12), weight: .bold))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Text(event.place)
                                .font(.system(size: RatioLen(10)))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, RatioLen(5.0))
                    .frame(width: RatioLen(110))
                }
            }
            .frame(width: RatioLen(165),height: cellHeight)
        } else {
            ZStack{
                RoundedRectangle(cornerRadius: RatioLen(12), style: .continuous)
                    .stroke(Color.gray, lineWidth: RatioLen(1))
                Text("无更多日程")
                    .font(.system(size: RatioLen(14)))
                    .foregroundColor(.gray)
            }
            .frame(width: RatioLen(165),height: cellHeight)
        }
    }
    
}

struct EventsView: View {
    var upcomingEvents: [WidgetEvent?]
    var body: some View {
            VStack{
                ForEach(0 ..< upcomingEvents.count, id: \.self){index in
                    if index > 0 {
                        Spacer(minLength: RatioLen(0))
                    }
                    EventCellView(event: upcomingEvents[index], cellHeight: RatioLen(35))
                }
            }
            .padding(.trailing, RatioLen(12.5))
            .padding(.top, RatioLen(14.5))
            .padding(.bottom, RatioLen(13.0))
    }
}

struct EventRingView: View {
    var event: WidgetEvent
    var currentDate: Date
    var multiplier: CGFloat
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack{
            Text(event.name)
                .font(.system(size: RatioLen(20) * multiplier, weight: .bold))
                .foregroundColor(event.mainColor)
                .lineLimit(1)
            Spacer()
            RingProgressView(event: event, currentDate: currentDate, width: RatioLen(100) * multiplier, color1: event.mainColor, color2: event.mainColor)
        }
        .frame(width: RatioLen(130) * multiplier)
        .padding(.top, RatioLen(14.0))
        .padding(.bottom, RatioLen(16.0))
        .padding(.horizontal, RatioLen(10.0))
    }
}

struct NothingView: View {
    var body: some View {
        Text("今日无事")
    }
}

private func ReloadCheck(_ events: [WidgetEvent], at date: Date) {
    let firstEndEvent: WidgetEvent? = events.sorted { $0.end <= $1.end }.first
    if let endDate = firstEndEvent?.end {
        guard endDate <= date else { return }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private func ReloadCheck(_ event: WidgetEvent, at date: Date) {
    guard event.end <= date else { return }
    WidgetCenter.shared.reloadAllTimelines()
}
