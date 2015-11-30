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

/// A session of API used to send login and resource requests.
class APISession: NSObject {
    
    /**
     Initialize a session of API with username and password.
     
     - parameter username: The username of jwbinfosys.
     - parameter password: The password of jwbinfosys.
     
     - returns: A session object initialized.
     */
    init(username: String, password: String) {
        self.username = username
        self.password = password
        super.init()
    }
    
    private let username: String
    private let password: String
    private var sessionId: String!
    private var sessionKey: String!
    
    
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
        return derivedKey.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
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
        let signature = mac.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        return signature.substringToIndex(signature.startIndex.advancedBy(lengthOfSignature))
    }
    
    
    // MARK: - JSON Conversions
    
    /**
     Create a UTF-8 encoded String from the given JSON object. Note it will CRASH if the JSON is invalid.
     
     - parameter object: A valid JSON object.
     
     - returns: A UTF-8 encoded String.
     */
    func stringFromJSONObject(object: AnyObject) -> String {
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions())
        return NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
    }
    
    func jsonObjectFromString(string: String) -> AnyObject {
        let jsonData = string.dataUsingEncoding(NSUTF8StringEncoding)!
        return try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
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
            "salt": salt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions()),
            "login": [
                "jwbinfosys": [
                    "userName": username,
                    "userPass": password
                ]
            ]
        ]
        let loginURL = NSURL(string: MobileAPIURL)!.URLByAppendingPathComponent("login")
        Alamofire.request(.POST, loginURL, parameters: postData, encoding: .JSON)
                 .responseJSON { response in
                    if response.result.isFailure {
                        callback(false, response.result.error!.description)
                        return
                    }
                    let json = JSON(response.result.value!)
                    if (json["status"].string == "ok") {
                        self.sessionId = json["sessionId"].string
                        self.sessionKey = json["sessionKey"].string
                        callback(true, nil)
                    } else {
                        callback(false, json["error"].string)
                    }
                 }
    }
    
    /**
     Send a resource request to API asynchronously and execute a closure after completion.
     
     - parameter requestList: A request list used in JSON.
     - parameter callback:    A closure to be executed once the request has finished. The first parameter is the response JSON, or nil if failed. The second one is the description of error.
     */
    private func resourceRequest(requestList: [AnyObject], callback: (JSON?, String?) -> Void) {
        if sessionId == nil || sessionKey == nil {
            // Delay processing until `sessionFail`
            sessionId = ""
            sessionKey = ""
        }
        let postData: [String: AnyObject] = [
            "sessionId": sessionId,
            "sessionKey": sessionKey,
            "requestList": stringFromJSONObject(requestList)
        ]
        let resourcesURL = NSURL(string: MobileAPIURL)!.URLByAppendingPathComponent("getResources")
        Alamofire.request(.POST, resourcesURL, parameters: postData, encoding: .JSON)
                 .responseJSON { response in
                    if response.result.isFailure {
                        callback(nil, response.result.error!.description)
                        return
                    }
                    let json = JSON(response.result.value!)
                    if (json["status"].string == "ok") {
                        if let responseList = json["responseList"].string {
                            let responseJSON = JSON(self.jsonObjectFromString(responseList))
                            callback(responseJSON[0]["data"], nil)
                        } else {
                            callback(nil, "The response list is null.")
                        }
                    } else if (json["status"].string == "sessionFail") {
                        self.loginRequest { status, error in
                            if status {
                                self.resourceRequest(requestList) { json, error in
                                    callback(json, error)
                                }
                            } else {
                                callback(nil, error)
                            }
                        }
                    } else {
                        callback(nil, json["error"].string)
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
                "uuid": "",
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"CourseAll\"}",
                "version": ""
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
                "uuid": "",
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"ExamAll\"}",
                "version": ""
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
                "uuid": "",
                "fetcher": "jwbInfoSystem",
                "data": "{\"action\":\"ScoreAll\"}",
                "version": ""
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
                "uuid": "",
                "fetcher": "staticInterface",
                "data": "{\"action\":\"schoolCal.all\"}",
                "version": ""
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
                "uuid": "",
                "fetcher": "staticInterface",
                "data": "{\"action\":\"schoolBus\"}",
                "version": ""
            ]
        ]
        resourceRequest(requestList, callback: callback)
    }
    
}
