//
//  AccountManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-29.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import KeychainAccess

/// The account manager of JWBInfoSys and ZJUWLAN. Singleton pattern is used in this class.
public class AccountManager: NSObject {
    
    /**
     Override just to make init() private.
     */
    private override init() {
        super.init()
    }
    
    public static let sharedInstance = AccountManager()
    
    private let groupDefaults = NSUserDefaults(suiteName: "group.com.zjuqsc.QSCMobileV3")!
    
    // MARK: - JWBInfoSys
    private let JwbinfosysCurrentAccountKey = "JwbinfosysCurrentAccount"
    private let jwbinfosysKeychain = Keychain(service: "com.zjuqsc.QSCMobileV3.jwbinfosys")
    
    /**
     Add an account to JWBInfoSys. If this account already exists, its password would be updated.
     */
    public func addAccountToJwbinfosys(username: String, password: String) {
        jwbinfosysKeychain[username] = password
    }
    
    /**
     Remove an account from JWBInfoSys.
     */
    public func removeAccountFromJwbinfosys(username: String) {
        jwbinfosysKeychain[username] = nil
    }
    
    /// Retrive all stored accounts of JWBInfoSys.
    public var allAccountsForJwbinfosys: [String] {
        return jwbinfosysKeychain.allKeys()
    }
    
    /// Get or set current account of JWBInfosys. If so far there is no account, you will get nil.
    public var currentAccountForJwbinfosys: String? {
        get {
            return groupDefaults.stringForKey(JwbinfosysCurrentAccountKey)
        }
        set {
            groupDefaults.setObject(newValue, forKey: JwbinfosysCurrentAccountKey)
            groupDefaults.synchronize()
        }
    }
    
    /**
     Retrive the password of the given account in JWBInfoSys.
     
     - parameter username: Username of the account.
     
     - returns: Password of the account or nil if username is not found.
     */
    public func passwordForJwbinfosys(username: String) -> String? {
        return jwbinfosysKeychain[username]
    }
    
    // MARK: - ZJUWLAN
    private let ZjuwlanAccountKey = "ZjuwlanAccount"
    private let zjuwlanKeychain = Keychain(service: "com.zjuqsc.QSCMobileV3.zjuwlan")
    
    /// Get or set username of ZJUWLAN. If so far there is no account, you will get nil.
    public var accountForZjuwlan: String? {
        get {
            return groupDefaults.stringForKey(ZjuwlanAccountKey)
        }
        set {
            groupDefaults.setObject(newValue, forKey: ZjuwlanAccountKey)
            groupDefaults.synchronize()
        }
    }
    
    /// Get or set password of ZJUWLAN. If username of ZJUWLAN hasn't been set, you will get nil and settings will fail gracefully.
    public var passwordForZjuwlan: String? {
        get {
            return accountForZjuwlan != nil ? zjuwlanKeychain[accountForZjuwlan!] : nil
        }
        set {
            if accountForZjuwlan != nil {
                zjuwlanKeychain[accountForZjuwlan!] = newValue
            }
        }
    }

}
