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
        return length
    }
}

let simpleConfig = ConfigurationIntent()

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> QSCWidgetEntry {
        QSCWidgetEntry(date: Date(), configuration: ConfigurationIntent(), events: [simpleEvent1, simpleEvent2], tomorrowEvents: [], style: .concise)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (QSCWidgetEntry) -> ()) {
        let entry = QSCWidgetEntry(date: Date(), configuration: configuration, events: simpleEvents, tomorrowEvents: [], style: .concise)
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
        let tomorrowWidgetEvents: [WidgetEvent] = upcomingEvents.count == 0 ? eventsForDate(Date().tomorrow).map{ return WidgetEvent(event: $0)} : []
        var style: EntryStyle
        switch configuration.style {
        case .concise:
            style = .concise
        default:
            style = .detailed
        }
        
        for _ in 0 ..< 60 {
            upcomingWidgetEvents = upcomingWidgetEvents.filter{ $0.end > currentDate}
            
            let entry = QSCWidgetEntry(date: currentDate, configuration: configuration, events: upcomingWidgetEvents, tomorrowEvents: tomorrowWidgetEvents, style: style)
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
        .configurationDisplayName("求是潮")
        .description("这是求是潮小组件")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QSCWidget_Previews: PreviewProvider {
    static var previews: some View {
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, tomorrowEvents: simpleTomorrowEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, tomorrowEvents: simpleTomorrowEvents, style: .detailed))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, tomorrowEvents: simpleTomorrowEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, tomorrowEvents: simpleTomorrowEvents, style: .detailed))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        QSCWidgetEntryView(entry: QSCWidgetEntry(date: Date(), configuration: simpleConfig, events: simpleEvents, tomorrowEvents: simpleTomorrowEvents, style: .concise))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

struct smallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack{
            WidgetBackground()
            if let firstEvent = entry.firstEvent {
                HStack{
                    switch entry.style {
                    case .concise:
                        EventRingView(event: firstEvent, currentDate: entry.date, multiplier: 1, isTomorrow: entry.isTomorrow)
                    default:
                        FirstEventView(firstEvent: firstEvent, currentDate: entry.date, isTomorrow: entry.isTomorrow)
                            Spacer(minLength: 0)
                    }
                }
            } else {
                NothingView()
            }
        }
    }
    
}

struct mediumWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        ZStack {
            WidgetBackground()
            if let firstEvent = entry.firstEvent {
                HStack{
                    switch entry.style {
                    case .concise:
                        EventRingView(event: firstEvent, currentDate: entry.date, multiplier: 1, isTomorrow: entry.isTomorrow)
                    default:
                        FirstEventView(firstEvent: firstEvent, currentDate: entry.date, isTomorrow: entry.isTomorrow)
                    }
                    Spacer(minLength: 0)
                    EventsView(upcomingEvents: entry.upcomingEvents, isTomorrow: entry.isTomorrow)
                }
            } else {
                NothingView()
            }
        }
    }
}

struct largeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            WidgetBackground()
            if let firstEvent = entry.firstEvent {
                switch entry.style {
                case .concise:
                    HStack{
                        EventRingView(event: firstEvent, currentDate: entry.date, multiplier: 2.4, isTomorrow: entry.isTomorrow)
                    }
                default:
                    HStack{
                        FirstEventView(firstEvent: firstEvent, currentDate: entry.date, isTomorrow: entry.isTomorrow)
                        Spacer(minLength: 0)
                    }
                }
            } else {
                NothingView()
            }
        }
        
    }
}

struct FirstEventView: View {
    let firstEvent: WidgetEvent
    let currentDate: Date
    let isTomorrow: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                if isTomorrow {
                    TomorrowIcon(mainColor: firstEvent.mainColor, mutiplier: 1.0)
                }
                Text(firstEvent.name)
                    .font(.system(size: RatioLen(20), weight: .bold))
                    .foregroundColor(firstEvent.mainColor)
                    .lineLimit(1)
            }
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
                Text(firstEvent.place.simplifiedPlaceString)
                    .font(.system(size: RatioLen(12), weight: .light))
                    .lineLimit(1)
            }
            HStack{
                Text("\u{F017}")
                    .font(.custom("FontAwesome", size: RatioLen(12)))
                let timeString = firstEvent.duration == Event.Duration.partialTime ? firstEvent.timeString(firstEvent.start) + "-" + firstEvent.timeString(firstEvent.end) : "全天"
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
                .stroke(Color(QSCColor.ringGray),
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
    let isTomorrow: Bool
    var body: some View {
        if let event = event {
            ZStack{
                RoundedRectangle(cornerRadius: RatioLen(12), style: .continuous)
                    .stroke(event.mainColor, lineWidth: RatioLen(1))
                HStack{
                    if event.duration == Event.Duration.partialTime {
                        VStack(alignment: .leading){
                            Text(event.timeString(event.start))
                                .font(.system(size: RatioLen(10)))
                                .foregroundColor(.gray)
                            Text(event.timeString(event.end))
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
                            HStack {
                                if isTomorrow {
                                    TomorrowIcon(mainColor: Color.black, mutiplier: 0.65)
                                        .padding(.trailing, RatioLen(-5))
                                }
                                Text(event.name)
                                    .font(.system(size: RatioLen(12)))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
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
            .frame(width: RatioLen(165),height: RatioLen(35))
        } else {
            ZStack{
                RoundedRectangle(cornerRadius: RatioLen(12), style: .continuous)
                    .stroke(Color.gray, lineWidth: RatioLen(1))
                Text(isTomorrow ? "无更多日程"  : "今日无更多日程" )
                    .font(.system(size: RatioLen(14)))
                    .foregroundColor(.gray)
            }
            .frame(width: RatioLen(165),height: RatioLen(35))
        }
    }
    
}

struct EventsView: View {
    var upcomingEvents: [WidgetEvent?]
    let isTomorrow: Bool
    
    var body: some View {
            VStack{
                if isTomorrow {
                    ZStack{
                        RoundedRectangle(cornerRadius: RatioLen(12), style: .continuous)
                            .stroke(Color.gray, lineWidth: RatioLen(1))
                        Text("今日无事")
                            .font(.system(size: RatioLen(14)))
                            .foregroundColor(.gray)
                    }
                    .frame(width: RatioLen(165),height: RatioLen(35))
                    Spacer(minLength: 0)
                }
                ForEach(0 ..< upcomingEvents.count, id: \.self){index in
                    if index > 0 {
                        Spacer(minLength: 0)
                    }
                    EventCellView(event: upcomingEvents[index], isTomorrow: isTomorrow)
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
    let isTomorrow: Bool
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack{
            HStack{
                if isTomorrow {
                    TomorrowIcon(mainColor: event.mainColor, mutiplier: 1.0)
                }
                Text(event.name)
                    .font(.system(size: RatioLen(20) * multiplier, weight: .bold))
                    .foregroundColor(event.mainColor)
                    .lineLimit(1)
            }
            Spacer()
            RingProgressView(event: event, currentDate: currentDate, width: RatioLen(100) * multiplier, color1: event.mainColor, color2: event.mainColor)
                .padding(.bottom, RatioLen(15.0))
        }
        .frame(width: RatioLen(130) * multiplier)
        .padding(.top, RatioLen(7.0))
        .padding(.horizontal, RatioLen(10.0))
    }
}

struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        switch colorScheme {
        case .dark:
            Color(QSCColor.darkGray)
        default:
            Color.white
        }
    }
}

struct TomorrowIcon: View {
    let mainColor: Color
    let mutiplier: CGFloat
    
    var body: some View {
        Text("明")
            .font(.system(size: RatioLen(9) * mutiplier))
            .foregroundColor(mainColor)
            .frame(width: RatioLen(16) * mutiplier, height: RatioLen(16) * mutiplier)
            .overlay(
                RoundedRectangle(cornerRadius: RatioLen(8) * mutiplier, style: .continuous)
                    .stroke(mainColor, lineWidth: RatioLen(1) * mutiplier)
            )
    }
}

struct NothingView: View {
    var body: some View {
        Text("今日无事")
    }
}
