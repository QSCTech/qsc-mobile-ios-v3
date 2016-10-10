//
//  APISession.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CryptoSwift

/// A session of API used to send login and resource requests. This class is used by mobile manager.
class APISession: NSObject {
    
    init(username: String, password: String) {
        accountManager = AccountManager.sharedInstance
        
        self.username = username
        self.password = password
        session = accountManager.sessionForCurrentAccount
        
        super.init()
    }
    
    private let alamofire = alamofireManager(timeoutInterval: 10)
    private let accountManager: AccountManager
    
    private let username: String
    private let password: String
    private var session: (id: String?, key: String?) {
        willSet {
            accountManager.sessionForCurrentAccount = newValue
        }
    }
    
    // MARK: - Helpers
    
    /**
     Generate salt for API login request. Salt should be random data of 6 bytes.
     
     - returns: Raw data of salt.
     */
    func generateSalt() -> [UInt8] {
        let bytesOfSalt = 6
        
        var salt = [UInt8]()
        for _ in 0..<bytesOfSalt {
            let byte = UInt8(arc4random_uniform(UInt32(UINT8_MAX)))
            salt.append(byte)
        }
        return salt
    }
    
    /**
     Create a UTF-8 encoded String from the given JSON object. Note it will CRASH if the JSON is invalid.
     
     - parameter object: A valid JSON object.
     
     - returns: A UTF-8 encoded String.
     */
    func stringFromJSONObject(_ object: AnyObject) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: object, options: [])
        return String(data: jsonData, encoding: String.Encoding.utf8)!
    }
    
    func jsonObjectFromString(_ string: String) -> AnyObject {
        let jsonData = string.data(using: String.Encoding.utf8)!
        return try! JSONSerialization.jsonObject(with: jsonData, options: []) as AnyObject
    }
    
    
    // MARK: - API Requests
    
    /**
     Send a login request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is whether the request is successful, and the second one is the description of error if failed.
     */
    func loginRequest(_ callback: @escaping (Bool, String?) -> Void) {
        let salt = generateSalt()
        let hash = try! PKCS5.PBKDF2(password: AppKey.utf8.map({$0}), salt: salt, iterations: 2048, keyLength: 6, variant: .sha1).calculate()
        let postData: [String: Any] = [
            "appKeyHash": hash.toBase64()!,
            "salt": salt.toBase64()!,
            "login": [
                "jwbinfosys": [
                    "userName": username,
                    "userPass": password,
                ]
            ]
        ]
        let loginURL = URL(string: MobileAPIURL)!.appendingPathComponent("login")
        alamofire.request(loginURL, method: .post, parameters: postData, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isFailure {
                let errorDescription = response.result.error!.localizedDescription.trimmingCharacters(in: CharacterSet(charactersIn: "。"))
                print("[Login request] Alamofire: \(errorDescription)")
                callback(false, errorDescription)
                return
            }
            let json = JSON(response.result.value!)
            let printError = {
                print("[Login request] \(json["status"].stringValue): \(json["error"].stringValue)")
            }
            if json["status"].string == "ok" {
                self.session = (json["sessionId"].string, json["sessionKey"].string)
                callback(true, nil)
            } else if json["error"].stringValue.contains("登录失败") {
                printError()
                callback(false, "用户名或密码错误")
            } else {
                printError()
                callback(false, "请求失败，请重试")
            }
        }
    }
    
    /**
     Send a resource request to API asynchronously and execute a closure after completion.
     
     - parameter requestList: A request list used in JSON.
     - parameter callback:    A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    private func resourceRequest(_ requestList: [[String: String]], callback: @escaping (JSON?, String?) -> Void) {
        if session.id == nil || session.key == nil {
            // Delay processing until `sessionFail`
            session = ("", "")
        }
        let request = stringFromJSONObject(requestList as AnyObject)
        let verify = try! HMAC(key: session.key!.utf8.map({$0}), variant: .sha1).authenticate(request.utf8.map({$0}))
        let postData: [String: Any] = [
            "sessionId": session.id!,
            "sessionVerify": verify.toBase64()!,
            "requestList": request,
        ]
        let resourcesURL = URL(string: MobileAPIURL)!.appendingPathComponent("getResources")
        alamofire.request(resourcesURL, method: .post, parameters: postData, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isFailure {
                let errorDescription = response.result.error!.localizedDescription.trimmingCharacters(in: CharacterSet(charactersIn: "。"))
                print("[Resource request] Alamofire: \(errorDescription) \(requestList[0]["data"]!)")
                callback(nil, errorDescription)
                return
            }
            let json = JSON(response.result.value!)
            let printError = {
                print("[Resource request] \(json["status"].stringValue): \(json["error"].stringValue)  \(requestList[0]["data"]!)")
            }
            if json["status"].string == "ok" {
                let responseData = JSON(self.jsonObjectFromString(json["responseList"].stringValue))[0]["data"]
                if responseData.exists() {
                    callback(responseData, nil)
                } else {
                    print("[Resource request] Response data is null")
                    callback(nil, "刷新失败，请重试")
                }
            } else if json["status"].string == "sessionFail" {
                printError()
                self.loginRequest { success, error in
                    if success {
                        self.resourceRequest(requestList, callback: callback)
                    } else {
                        callback(nil, error)
                    }
                }
            } else if json["status"].string == "requestFail" {
                printError()
                callback(nil, "教务网通知，请登录网站查收")
            } else {
                printError()
                callback(nil, "刷新失败，请重试")
            }
        }
    }
    
    /**
     Send a course request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func courseRequest(_ callback: @escaping (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"CourseAll\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
    /**
     Send a exam request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func examRequest(_ callback: @escaping (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"ExamAll\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
    /**
     Send a score request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func scoreRequest(_ callback: @escaping (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"ScoreAll\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList) { json, error in
            if let json = json {
                if json["scoreObject"].dictionaryValue.isEmpty {
                    print("[Score request] Score object is empty")
                    callback(nil, "")
                } else {
                    callback(json, nil)
                }
            } else {
                callback(nil, error)
            }
        }
    }
    
    /**
     Send a statistics  request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func statisticsRequest(_ callback: @escaping (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"Statistics\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
    /**
     Send a calendar request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func calendarRequest(_ callback: @escaping (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "staticInterface",
                "data": "{\"key\":\"schoolCal.all\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
    /**
     Send a bus request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func busRequest(_ callback: @escaping (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "staticInterface",
                "data": "{\"key\":\"schoolBus\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
}
