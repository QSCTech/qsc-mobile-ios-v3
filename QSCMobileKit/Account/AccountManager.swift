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
    
    public static let sharedInstance = AccountManager()
        
    // MARK: - JWBInfoSys
    private let jwbinfosysKeychain = Keychain(server: "http://jwbinfosys.zju.edu.cn", protocolType: .HTTP)
    private let JwbinfosysCurrentAccountKey = "JwbinfosysCurrentAccount"
    private let JwbinfosysSessionId = "JwbinfosysSessionId"
    private let JwbinfosysSessionKey = "JwbinfosysSessionKey"
    
    /**
     Add an account to JWBInfoSys and set it to current account.
     */
    func addAccountToJwbinfosys(username: String, _ password: String) {
        jwbinfosysKeychain[username] = password
        currentAccountForJwbinfosys = username
    }
    
    /**
     Remove an account from JWBInfoSys.
     */
    func removeAccountFromJwbinfosys(username: String) {
        jwbinfosysKeychain[username] = nil
        if currentAccountForJwbinfosys == username {
            currentAccountForJwbinfosys = allAccountsForJwbinfosys.first
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
    
    /// Get or set session id and key of JWBInfoSys. This property is represented as a tuple, either of which can be nil.
    var sessionForCurrentAccount: (id: String?, key: String?) {
        get {
            return (groupDefaults.stringForKey(JwbinfosysSessionId), groupDefaults.stringForKey(JwbinfosysSessionKey))
        }
        set {
            groupDefaults.setObject(newValue.id, forKey: JwbinfosysSessionId)
            groupDefaults.setObject(newValue.key, forKey: JwbinfosysSessionKey)
            groupDefaults.synchronize()
        }
    }
    
    /**
     Retrieve the password of the given account in JWBInfoSys.
     
     - parameter username: Username of the account.
     
     - returns: Password of the account or nil if username is not found.
     */
    public func passwordForJwbinfosys(username: String) -> String? {
        return jwbinfosysKeychain[username]
    }
    
    // MARK: - ZJUWLAN
    private let ZjuwlanAccountKey = "ZjuwlanAccount"
    private let zjuwlanKeychain = Keychain(server: "https://net.zju.edu.cn", protocolType: .HTTPS)
    
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
