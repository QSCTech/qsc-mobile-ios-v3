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
    
    // MARK: - Hash Functions
    
    /**
     Generate salt for API login request. Salt should be random data of 6 bytes.
     
     - returns: Raw data of salt.
     */
    func generateSalt() -> NSData {
        let bytesOfSalt = 6
        
        let salt = NSMutableData(capacity: bytesOfSalt)!
        for _ in 0..<bytesOfSalt {
            var byte = UInt8(arc4random_uniform(UInt32(UINT8_MAX)))
            salt.appendBytes(&byte, length: 1)
        }
        return salt
    }
    
    /**
     Generate `appKeyHash` for API login request. It uses PBKDF2-HMAC-SHA1 algorithm which iterates 2048 times and derives a key of 6 bytes encoded with Base64.
     
     - parameter password: The password from which a derived key is generated. Here it should be the original `appKey`.
     - parameter salt:     The cryptographic salt generated before.
     
     - returns: The derived key encoded with Base64, used for `appKeyHash`.
     */
    func pbkdf2HmacSha1(password password: String, salt: NSData) -> String {
        let numberOfIterations = 2048
        let bytesOfDerivedKey  = 6
        
        let password = password.dataUsingEncoding(NSUTF8StringEncoding)!
        let derivedKey = NSMutableData(length: bytesOfDerivedKey)!
        CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            UnsafePointer<Int8>(password.bytes), password.length,
            UnsafePointer<UInt8>(salt.bytes), salt.length,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            UInt32(numberOfIterations),
            UnsafeMutablePointer<UInt8>(derivedKey.mutableBytes), derivedKey.length
        )
        return derivedKey.base64EncodedStringWithOptions([])
    }
    
    /**
     Generate a signature for API resource request list. This signature uses HMAC-SHA1 algorithm and return the first 36 bits encoded with Base64.
     
     - parameter key:     The secret key used in HMAC. Here it should be `sessionKey`.
     - parameter message: The message to be authenticated. Here it should be `requestList`.
     
     - returns: The signature encoded with Base64, used for `sessionVerify`.
     */
    func hmacSha1(key key: String, message: String) -> String {
        let lengthOfSignature = 6
        
        let key = key.dataUsingEncoding(NSUTF8StringEncoding)!
        let message = message.dataUsingEncoding(NSUTF8StringEncoding)!
        let mac = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CCHmac(
            CCHmacAlgorithm(kCCHmacAlgSHA1),
            key.bytes, key.length,
            message.bytes, message.length,
            mac.mutableBytes
        )
        let signature = mac.base64EncodedStringWithOptions([])
        return signature.substringToIndex(signature.startIndex.advancedBy(lengthOfSignature))
    }
    
    
    // MARK: - JSON Conversions
    
    /**
     Create a UTF-8 encoded String from the given JSON object. Note it will CRASH if the JSON is invalid.
     
     - parameter object: A valid JSON object.
     
     - returns: A UTF-8 encoded String.
     */
    func stringFromJSONObject(object: AnyObject) -> String {
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(object, options: [])
        return String(data: jsonData, encoding: NSUTF8StringEncoding)!
    }
    
    func jsonObjectFromString(string: String) -> AnyObject {
        let jsonData = string.dataUsingEncoding(NSUTF8StringEncoding)!
        return try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
    }
    
    
    // MARK: - API Requests
    
    /**
     Send a login request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is whether the request is successful, and the second one is the description of error if failed.
     */
    func loginRequest(callback: (Bool, String?) -> Void) {
        let salt = generateSalt()
        let postData: [String: AnyObject] = [
            "appKeyHash": pbkdf2HmacSha1(password: AppKey, salt: salt),
            "salt": salt.base64EncodedStringWithOptions([]),
            "login": [
                "jwbinfosys": [
                    "userName": username,
                    "userPass": password,
                ]
            ]
        ]
        let loginURL = NSURL(string: MobileAPIURL)!.URLByAppendingPathComponent("login")
        alamofire.request(.POST, loginURL, parameters: postData, encoding: .JSON).responseJSON { response in
            if response.result.isFailure {
                print("[Login request] Alamofire: \(response.result.error!.localizedDescription)")
                callback(false, "网络连接失败")
                return
            }
            let json = JSON(response.result.value!)
            let printError = {
                print("[Login request] \(json["status"].stringValue): \(json["error"].stringValue)")
            }
            if json["status"].string == "ok" {
                self.session = (json["sessionId"].string, json["sessionKey"].string)
                callback(true, nil)
            } else if json["error"].stringValue.containsString("登录失败") {
                printError()
                callback(false, "用户名或密码错误")
            } else {
                printError()
                callback(false, "登录失败，请重试")
            }
        }
    }
    
    /**
     Send a resource request to API asynchronously and execute a closure after completion.
     
     - parameter requestList: A request list used in JSON.
     - parameter callback:    A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    private func resourceRequest(requestList: [AnyObject], callback: (JSON?, String?) -> Void) {
        if session.id == nil || session.key == nil {
            // Delay processing until `sessionFail`
            session = ("", "")
        }
        let postData: [String: AnyObject] = [
            "sessionId": session.id!,
            "sessionKey": session.key!,
            "requestList": stringFromJSONObject(requestList),
        ]
        let resourcesURL = NSURL(string: MobileAPIURL)!.URLByAppendingPathComponent("getResources")
        alamofire.request(.POST, resourcesURL, parameters: postData, encoding: .JSON).responseJSON { response in
            if response.result.isFailure {
                print("[Resource request] Alamofire: \(response.result.error!.localizedDescription)")
                callback(nil, "网络连接失败")
                return
            }
            let json = JSON(response.result.value!)
            let printError = {
                print("[Resource request] \(json["status"].stringValue): \(json["error"].stringValue)")
            }
            if json["status"].string == "ok" {
                if let responseList = json["responseList"].string {
                    let responseJSON = JSON(self.jsonObjectFromString(responseList))
                    callback(responseJSON[0]["data"], nil)
                } else {
                    print("[Resource request] Response list is null")
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
                callback(nil, "教务网通知，请查收")
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
    func courseRequest(callback: (JSON?, String?) -> Void) {
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
    func examRequest(callback: (JSON?, String?) -> Void) {
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
    func scoreRequest(callback: (JSON?, String?) -> Void) {
        let requestList = [
            [
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"ScoreAll\"}",
                "uuid": "",
                "version": "",
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
    /**
     Send a statistics  request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    func statisticsRequest(callback: (JSON?, String?) -> Void) {
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
    func calendarRequest(callback: (JSON?, String?) -> Void) {
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
    func busRequest(callback: (JSON?, String?) -> Void) {
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
