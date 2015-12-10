//
//  ZjuwlanConnection.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-09.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import Alamofire

public class ZjuwlanConnection: NSObject {
    
    /// Get SSID of current network, or an empty string. Note this method uses deprecated APIs since iOS 9.0.
    public static var currentSSID: String {
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
    
    /**
     Connect VPN under ZJUWLAN. This method tries to logout first in case that VPN has been logged in at another place.
     
     - parameter callback: A closure to be executed once login request has finished. The first parameter is whether the connection is successful, and the second one is the description of error if failed.
     */
    public static func link(callback: (Bool, String?) -> Void) {
        let accountManager = AccountManager.sharedInstance
        if accountManager.accountForZjuwlan == nil {
            callback(false, "未输入 ZJUWLAN 账号")
            return
        }
        let username = accountManager.accountForZjuwlan!
        let password = accountManager.passwordForZjuwlan!
        
        logout(username, password) { status, error in
            if status {
                login(username, password, callback: callback)
            } else {
                callback(false, error)
            }
        }
    }
    
    private static func login(username: String, _ password: String, callback: (Bool, String?) -> Void) {
        let postData: [String: AnyObject] = [
            "action": "login",
            "username": username,
            "password": password,
            "ac_id": 5,
            "is_ldap": 1,
            "type": 2,
            "local_auth": 1
        ]
        Alamofire.request(.POST, ZjuwlanLoginURL, parameters: postData)
                 .responseString { response in
                    if let string = response.result.value {
                        if string.containsString("ok") {
                            callback(true, nil)
                        } else {
                            callback(false, "用户名或密码错误")
                        }
                    } else {
                        callback(false, "网络连接失败")
                    }
                 }
    }
    
    private static func logout(username: String, _ password: String, callback: (Bool, String?) -> Void) {
        let postData: [String: AnyObject] = [
            "action": "auto_dm",
            "username": username,
            "password": password
        ]
        Alamofire.request(.POST, ZjuwlanLogoutURL, parameters: postData)
                 .responseString { response in
                    if let string = response.result.value {
                        if string.containsString("ok") {
                            callback(true, nil)
                        } else {
                            callback(false, "用户名或密码错误")
                        }
                    } else {
                        callback(false, "网络连接失败")
                    }
                 }
    }
    
}
