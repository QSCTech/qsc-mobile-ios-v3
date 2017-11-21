//
//  ZjuwlanConnection.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-09.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import Alamofire

private let ZJUWLAN_URL  = "https://net.zju.edu.cn/include/auth_action.php"
private let MYVPN_URL = "http://myvpn.zju.edu.cn/login.action"

public class ZjuwlanConnection: NSObject {
    
    private static let alamofire = alamofireManager(timeoutInterval: 10)
    
    /**
     Connect VPN under ZJUWLAN. This method tries to logout first in case that VPN has been logged in at another place.
     
     - parameter callback: A closure to be executed once login request has finished. The argument will be nil if the connection has established, otherwise it will be the description of error.
     */
    public static func link(_ callback: @escaping (String?) -> Void) {
        let accountManager = AccountManager.sharedInstance
        if accountManager.accountForZjuwlan == nil {
            callback("未输入 ZJUWLAN 账号")
            return
        }
        let username = accountManager.accountForZjuwlan!
        let password = accountManager.passwordForZjuwlan!
        
        login(username, password, callback: callback)
    }
    
    private static func login(_ username: String, _ password: String, callback: @escaping (String?) -> Void) {
        let headers = ["Referer": "https://net.zju.edu.cn/srun_portal_phone.php?url=http://www.zju.edu.cn/&ac_id=3"]
        let postData = [
            "action": "login",
            "username": username,
            "password": password,
            "ac_id": "3",
            "user_ip": "",
            "nas_ip": "",
            "user_max": "",
            "save_me": "0",
            "ajax": "1",
        ]
        alamofire.request(ZJUWLAN_URL, method: .post, parameters: postData, headers: headers).responseData { response in
            if let result = response.result.value {
                let string = (String(data: result, encoding: String.Encoding.utf8) ?? "未知错误").trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                if string.contains("login_ok") {
                    callback(nil)
                } else if string.contains("IP地址异常") {
                    callback("您未连接到 ZJUWLAN")
                } else {
                    callback(string)
                }
            } else {
                let errorDescription = response.result.error!.localizedDescription.trimmingCharacters(in: CharacterSet(charactersIn: "。"))
                callback(errorDescription)
            }
        }
    }
    
    public static var isOnCampus: Bool {
        var result = true
        let semaphore = DispatchSemaphore(value: 0)
        alamofire.request(MYVPN_URL).validate(statusCode: 200..<300).responseData(queue: DispatchQueue.global(qos: .default)) { response in
            result = response.result.isSuccess
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
    
}
