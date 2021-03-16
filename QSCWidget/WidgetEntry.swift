//
//  WidgetEntry.swift
//  QSCWidgetExtension
//
//  Created by Apple on 2021/3/13.
//  Copyright © 2021 QSC Tech. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit
import QSCMobileKit

struct QSCWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    
    let events: [WidgetEvent]
    let tomorrowEvents: [WidgetEvent]
    let style: EntryStyle
    
    var firstEvent: WidgetEvent? {
        return self.events.first(where: { $0.duration == Event.Duration.partialTime }) ?? self.events.first(where: { $0.duration == Event.Duration.allDay }) ?? self.tomorrowEvents.first(where: { $0.duration == Event.Duration.partialTime }) ?? self.tomorrowEvents.first(where: { $0.duration == Event.Duration.allDay })
    }
    
    var isTomorrow: Bool {
        return self.events.count == 0
    }
    
    var upcomingEvents: [WidgetEvent?] {
        var upcomingEvents: [WidgetEvent?] = Array(self.isTomorrow ? self.tomorrowEvents.prefix(2) : self.events.prefix(3))
        for _ in upcomingEvents.endIndex ..< (self.isTomorrow ? 2 : 3) {
            upcomingEvents.append(nil)
        }
        return upcomingEvents
    }
}

enum EntryStyle {
    case detailed
    case concise
}
