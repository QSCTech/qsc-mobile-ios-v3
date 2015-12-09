//
//  ZjuwlanConnection.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-09.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class ZjuwlanConnection: NSObject {
    
    /// Get SSID of current network, or an empty string. Note this method uses deprecated APIs since iOS 9.0.
    static var currentSSID: String {
        var ssid = ""
        if let interfaces = CNCopySupportedInterfaces() {
            let interfaces = interfaces as Array
            for interfaceName in interfaces {
                let interfaceName = String(interfaceName)
                if let networkInfo = CNCopyCurrentNetworkInfo(interfaceName) {
                    let networkInfo = networkInfo as Dictionary
                    ssid = networkInfo[kCNNetworkInfoKeySSID] as! String
                }
            }
        }
        return ssid
    }
    
}
