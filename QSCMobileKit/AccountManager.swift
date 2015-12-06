//
//  AccountManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-29.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import KeychainAccess

/// The account manager of JWBInfoSys and ZJUWLAN. This class does NOT handle login validation, which is in the control of mobile manager. Singleton pattern is used in this class.
public class AccountManager: NSObject {
    
    /**
     Override just to make init() private.
     */
    private override init() {
        super.init()
    }
    
    static let sharedInstance = AccountManager()
    
    private let groupDefaults = NSUserDefaults(suiteName: "group.com.zjuqsc.QSCMobileV3")!
    
    // MARK: - JWBInfoSys
    private let JwbinfosysCurrentAccountKey = "JwbinfosysCurrentAccount"
    private let jwbinfosysKeychain = Keychain(service: "com.zjuqsc.QSCMobileV3.jwbinfosys")
    
    /**
     Add an account to JWBInfoSys and set it to current account.
     */
    func addAccountToJwbinfosys(username: String, password: String) {
        jwbinfosysKeychain[username] = password
        currentAccountForJwbinfosys = username
    }
    
    // TODO: Modify password from UI.
    /**
     Modify the password of the specified account.
     */
    func modifyAccountOfJwbinfosys(username: String, password: String) {
        jwbinfosysKeychain[username] = password
    }
    
    /**
     Remove an account from JWBInfoSys.
     */
    func removeAccountFromJwbinfosys(username: String) {
        jwbinfosysKeychain[username] = nil
        if currentAccountForJwbinfosys == username {
            currentAccountForJwbinfosys = nil
        }
    }
    
    /// Retrieve all stored accounts of JWBInfoSys.
    public var allAccountsForJwbinfosys: [String] {
        return jwbinfosysKeychain.allKeys()
    }
    
    /// Get or set current account of JWBInfosys. If so far there is no account, you will get nil. If you want to change current account from UI, you should call `MobileManager.changeUser()`.
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
     Retrieve the password of the given account in JWBInfoSys.
     
     - parameter username: Username of the account.
     
     - returns: Password of the account or nil if username is not found.
     */
    func passwordForJwbinfosys(username: String) -> String? {
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
            if let account = accountForZjuwlan {
                zjuwlanKeychain[account] = newValue
            }
        }
    }

}
