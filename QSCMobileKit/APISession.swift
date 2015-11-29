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

class APISession: NSObject {
    
    /**
     Initialize a session of API with username and password.
     
     - parameter username: The username of jwbinfosys.
     - parameter password: The password of jwbinfosys.
     
     - returns: A session object initialized.
     */
    init(username: String, password: String) {
        super.init()
        self.username = username
        self.password = password
    }
    
    private var username: String!
    private var password: String!
    private var sessionId: String!
    private var sessionKey: String!

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
    
    /**
     Send a login request to API asynchronously and execute a closure after completion.
     
     - parameter callback: A closure to be executed once the request has finished. The first parameter is whether the request is successful, and the second one is the description of error.
     */
    func loginRequest(callback: (Bool, String?) -> Void) {
        var postData = [String: AnyObject]()
        
        let salt = generateSalt()
        postData["salt"] = salt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        postData["appKeyHash"] = pbkdf2HmacSha1(password: AppKey, salt: salt)
        
        let jwbinfosysData = ["userName": username, "userPass": password]
        postData["login"] = ["jwbinfosys": jwbinfosysData]
        
        let loginURL = NSURL(string: MobileAPIURL)!.URLByAppendingPathComponent("login")
        Alamofire.request(.POST, loginURL, parameters: postData, encoding: .JSON)
                 .responseJSON { response in
                    if response.result.isFailure {
                        callback(false, "网络错误：" + response.result.error!.description)
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
     - parameter callback:    A closure to be executed once the request has finished. The first parameter is the response JSON, and the second one is the description of error.
     */
    func resourceRequest(requestList: [AnyObject], callback: (JSON?, String?) -> Void) {
        if sessionId == nil || sessionKey == nil {
            // Delay processing until `sessionFail`
            sessionId = ""
            sessionKey = ""
        }
        var postData = [String: String]()
        postData["sessionId"] = sessionId
        postData["sessionKey"] = sessionKey
        let requestData = try! NSJSONSerialization.dataWithJSONObject(requestList, options: NSJSONWritingOptions())
        postData["requestList"] = NSString(data: requestData, encoding: NSUTF8StringEncoding)! as String
        
        let resourcesURL = NSURL(string: MobileAPIURL)!.URLByAppendingPathComponent("getResources")
        Alamofire.request(.POST, resourcesURL, parameters: postData, encoding: .JSON)
                 .responseJSON { response in
                    if response.result.isFailure {
                        callback(nil, "网络错误：" + response.result.error!.description)
                        return
                    }
                    let json = JSON(response.result.value!)
                    if (json["status"].string == "ok") {
                        callback(json["responseList"], nil)
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

}
