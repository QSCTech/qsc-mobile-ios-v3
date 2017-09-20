//
//  SchoolBus.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import Foundation

public class SchoolBus: NSObject {
    
    public init(from: String, to: String, isWeekend: Bool) {
        var stops = [(from: BusStop, to: BusStop)]()
        let fromStops = DataStore.busStopsOnCampus(from)
        for fromStop in fromStops {
            for stop in fromStop.bus!.busStops! {
                let stop = stop as! BusStop
                if stop.index! > fromStop.index! && stop.campus == to {
                    if (isWeekend && !fromStop.bus!.serviceDays!.contains("周六")) ||
                       (!isWeekend && !fromStop.bus!.serviceDays!.contains("周一")) {
                        continue
                    }
                    stops.append((fromStop, stop))
                }
            }
        }
        busStops = stops
        count = busStops.count
    }
    
    private let busStops: [(from: BusStop, to: BusStop)]
    
    public let count: Int
    
    public func fromTime(_ index: Int) -> String {
        return busStops[index].from.time!
    }
    
    public func toTime(_ index: Int) -> String {
        return busStops[index].to.time!
    }
    
    public func busName(_ index: Int) -> String {
        return busStops[index].from.bus!.name!
    }
    
    public func busNote(_ index: Int) -> String {
        return busStops[index].from.bus!.note!
    }
    
}
