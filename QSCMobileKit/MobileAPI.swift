//
//  MobileAPI.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation

class MobileAPI: NSObject {

    /**
     Generate salt for API login request. Salt should be random data of 6 bytes and encoded with Base64.
     
     - returns: Salt encoded with Base64.
     */
    private func generateSalt() -> String {
        let bytesOfSalt = 6
        
        let data = NSMutableData(capacity: bytesOfSalt)!
        for _ in 0..<bytesOfSalt {
            var byte = UInt8(arc4random_uniform(UInt32(UINT8_MAX)))
            data.appendBytes(&byte, length: 1)
        }
        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
    
    /**
     Generate `appKeyHash` for API login request. It uses PBKDF2-HMAC-SHA1 algorithm which iterates 2048 times and derives a key of 6 bytes encoded with Base64.
     
     - parameter password: The password from which a derived key is generated. Here it should be the original `appKey`.
     - parameter salt:     The cryptographic salt generated before.
     
     - returns: The derived key encoded with Base64, used for `appKeyHash`.
     */
    private func pbkdf2HmacSha1(password: String, salt: String) -> String {
        let numberOfIterations = 2048
        let bytesOfDerivedKey  = 6
        
        let password = password.dataUsingEncoding(NSUTF8StringEncoding)!
        let salt = NSData(base64EncodedString: salt, options: NSDataBase64DecodingOptions(rawValue: 0))!
        let derivedKey = NSMutableData(length: bytesOfDerivedKey)!
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                             UnsafePointer<Int8>(password.bytes), password.length,
                             UnsafePointer<UInt8>(salt.bytes), salt.length,
                             CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                             UInt32(numberOfIterations),
                             UnsafeMutablePointer<UInt8>(derivedKey.mutableBytes), derivedKey.length)
        return derivedKey.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
    
    /**
     Generate a signature for API resource request list. This signature uses HMAC-SHA1 algorithm and return the first 36 bits encoded with Base64.
     
     - parameter key:     The secret key used in HMAC. Here it should be `sessionKey`.
     - parameter message: The message to be authenticated. Here it should be `requestList`.
     
     - returns: The signature encoded with Base64, used for `sessionVerify`.
     */
    private func hmacSha1(key: String, message: String) -> String {
        let lengthOfSignature = 6
        
        let key = key.dataUsingEncoding(NSUTF8StringEncoding)!
        let message = message.dataUsingEncoding(NSUTF8StringEncoding)!
        let mac = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key.bytes, key.length, message.bytes, message.length, mac.mutableBytes)
        let signature = mac.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return signature.substringToIndex(signature.startIndex.advancedBy(lengthOfSignature))
    }
    
}
