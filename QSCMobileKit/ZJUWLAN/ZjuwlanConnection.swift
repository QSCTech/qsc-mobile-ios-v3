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
    
    private static let alamofire = alamofireManager(timeoutInterval: 10)
    
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
        
        login(username, password, callback: callback)
    }
    
    private static let ZjuwlanLoginURL  = "https://net.zju.edu.cn/include/auth_action.php"
    
    private static func login(username: String, _ password: String, callback: (Bool, String?) -> Void) {
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
        alamofire.request(.POST, ZjuwlanLoginURL, parameters: postData, headers: headers).responseData { response in
            if let result = response.result.value {
                let string = (String(data: result, encoding: NSUTF8StringEncoding) ?? "未知错误").stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "()"))
                if string.containsString("login_ok") {
                    callback(true, nil)
                } else if string.containsString("IP地址异常") {
                    callback(false, "您未连接到 ZJUWLAN")
                } else {
                    callback(false, string)
                }
            } else {
                let errorDescription = response.result.error!.localizedDescription.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "。"))
                callback(false, errorDescription)
            }
        }
    }
    
}
