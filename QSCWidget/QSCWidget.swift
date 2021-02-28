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
}

enum EntryStyle {
    case detailed
    case concise
}

let startTime1 = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
let endTime1 = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

let time1 = startTime1.stringOfDatetime + "-" + endTime1.stringOfDatetime
let name1 = "沟通技巧"
let place1 = "紫金港西2-103（录播)"
let simpleEvent1 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name1, time: time1, place: place1, start: startTime1, end: endTime1)

let startTime2 = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
let endTime2 = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
let time2 = startTime2.stringOfDatetime + "-" + endTime2.stringOfDatetime
let name2 = "面向对象程序设计"
let place2 = "紫金港西1-102（录播）"
let simpleEvent2 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name2, time: time2, place: place2, start: startTime2, end: endTime2)

let startTime3 = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
let endTime3 = Calendar.current.date(byAdding: .hour, value: 5, to: Date())!
let time3 = startTime3.stringOfDatetime + "-" + endTime3.stringOfDatetime
let name3 = "概率论与数理统计"
let place3 = "紫金港西2-202（录播研）#37"
let simpleEvent3 = WidgetEvent(duration: Event.Duration.partialTime, category: Event.Category.course, tags: [], name: name3, time: time3, place: place3, start: startTime3, end: endTime3)

let simpleEvents = [simpleEvent1, simpleEvent2, simpleEvent3]

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
        
        let currentDate = Date() - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60)
        for minuteOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            
            let upcomingEvents = events.filter { $0.end >= entryDate }
            let upcomingWidgetEvents = upcomingEvents.map{ return WidgetEvent(event: $0) }
            
            var style: EntryStyle
            switch configuration.style {
            case .concise:
                style = .concise
            default:
                style = .detailed
            }
            
            let entry = QSCWidgetEntry(date: entryDate, configuration: configuration, events: upcomingWidgetEvents, style: style)
            entries.append(entry)
            
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
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
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

struct smallWidgetView: View {
    var entry: Provider.Entry
    
    var firstEvent: WidgetEvent? {
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime })
    }
    
    var body: some View {
        if let firstEvent = firstEvent {
            switch entry.style {
            case .concise:
                HStack{
                    EventRingView(event: firstEvent, multiplier: 1)
                }
            default:
                HStack{
                    FirstEventView(firstEvent: firstEvent)
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
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime })
    }
    
    var upcomingEvents: [WidgetEvent] {
        Array(entry.events.prefix(3))
    }
    
    var body: some View {
        if let firstEvent = firstEvent {
            HStack{
                switch entry.style {
                case .concise:
                    EventRingView(event: firstEvent, multiplier: 1)
                default:
                    FirstEventView(firstEvent: firstEvent)
                }
                Spacer(minLength: 0)
                EventsView(upcomingEvents: upcomingEvents)
            }
            .padding(.horizontal, 10.0)
        } else {
            NothingView()
        }
    }
}

struct largeWidgetView: View {
    var entry: Provider.Entry
    
    var firstEvent: WidgetEvent? {
        return entry.events.first(where: { $0.duration == Event.Duration.partialTime })
    }
    
    var body: some View {
        if let firstEvent = firstEvent {
            switch entry.style {
            case .concise:
                HStack{
                    EventRingView(event: firstEvent, multiplier: 2.4)
                }
            default:
                HStack{
                    FirstEventView(firstEvent: firstEvent)
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
    
    var body: some View {
        ZStack{
            Color.white
            VStack(alignment: .leading){
                Text(firstEvent.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(firstEvent.mainColor)
                    .lineLimit(1)
                Spacer()
                if Date() < firstEvent.start {
                    Text("距日程开始")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray)
                    Text(firstEvent.start.timeIntervalSince(Date()).timeDescription)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(firstEvent.mainColor)
                } else {
                    Text("距日程结束")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray)
                    Text(firstEvent.end.timeIntervalSince(Date()).timeDescription)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(firstEvent.mainColor)
                }
                Spacer()
                HStack{
                    Text("\u{F041}")
                        .font(.custom("FontAwesome", size: 12))
                    Text(firstEvent.place)
                        .font(.system(size: 12, weight: .light))
                }
                HStack{
                    Text("\u{F017}")
                        .font(.custom("FontAwesome", size: 12))
                    let timeString = firstEvent.start.stringOfTime + "-" + firstEvent.end.stringOfTime
                    Text(timeString)
                        .font(.system(size: 12, weight: .light))
                        .padding(.leading, -3)
                }
                .padding(.leading, -2)
                
            }
            .frame(width: 135, height: 135, alignment: .leading)
            .padding(.leading,  15)
        }
        
    }
}

struct RingProgressView: View {
    let event: WidgetEvent
    var width: CGFloat = 80
    var percent: CGFloat {
        if Date().tomorrow <= event.start {
            let days = Int(event.start.today.timeIntervalSince(Date().today) / 86400)
            return CGFloat(30 - days) / 30.0
        } else if Date() < event.start {
            return CGFloat(Date().timeIntervalSince(Date().today)) / CGFloat(event.start.timeIntervalSince(Date().today))
        } else if Date() <= event.end {
            return CGFloat(Date().timeIntervalSince(event.start)) / CGFloat(event.end.timeIntervalSince(event.start))
        } else {
            return 0
        }
    }
    var color1: Color
    var color2: Color
    
    var body: some View {
        let mutiplier = width / 80
        let progress = 1 - percent
        
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.1),
                        style: StrokeStyle(lineWidth: 5 * mutiplier))
                .frame(width: width, height: width)
            
            Circle()
                .trim(from: progress, to: 1)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 5 * mutiplier, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .frame(width: width, height: width)
                .shadow(color: color1.opacity(0.1), radius: 3, x: 0, y: 3)
            VStack{
                if Date() < event.start {
                    Text("距开始")
                        .font(.system(size: 10 * mutiplier, weight: .light))
                        .foregroundColor(.gray)
                    Text(event.start.timeIntervalSince(Date()).timeDescription)
                        .font(.system(size: 20 * mutiplier, weight: .bold))
                        .foregroundColor(event.mainColor)
                } else {
                    Text("距结束")
                        .font(.system(size: 10 * mutiplier, weight: .light))
                        .foregroundColor(.gray)
                    Text(event.end.timeIntervalSince(Date()).timeDescription)
                        .font(.system(size: 20 * mutiplier, weight: .bold))
                        .foregroundColor(event.mainColor)
                }
            }
        }
    }
}
struct EventCellView: View {
    let event: WidgetEvent
    let cellHeight: CGFloat
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(event.mainColor, lineWidth: 1)
            HStack{
                VStack(alignment: .leading){
                    Text(event.start.stringOfTime)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(event.end.stringOfTime)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5.0)
                .frame(width: 40)
                HStack{
                    VStack(alignment: .leading){
                        Text(event.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        Text(event.place)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 5.0)
                .frame(width: 110)
            }
        }
        .frame(width: 165,height: cellHeight)
    }
    
}

struct EventsView: View {
    var upcomingEvents: [WidgetEvent]
    var body: some View {
            VStack{
                Spacer()
                ForEach(upcomingEvents, id: \.self){event in
                    EventCellView(event: event, cellHeight: 35)
                    Spacer(minLength: 10)
                }
            }
    }
}

struct EventRingView: View {
    var event: WidgetEvent
    var multiplier: CGFloat
    
    var body: some View {
        VStack{
            Text(event.name)
                .font(.system(size: 20 * multiplier, weight: .bold))
                .foregroundColor(event.mainColor)
                .lineLimit(1)
            Spacer()
            RingProgressView(event: event, width: 100 * multiplier, color1: event.mainColor, color2: event.mainColor)
        }
        .frame(width: 130 * multiplier)
        .padding(.vertical)
    }
}

struct NothingView: View {
    var body: some View {
        Text("今日无事")
    }
}
