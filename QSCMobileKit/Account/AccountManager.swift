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
    
    private override init() {
        super.init()
        
        // Prevent crashing when app is removed and installed again.
        if currentAccountForJwbinfosys == nil && !jwbinfosysKeychain.allKeys().isEmpty {
            try! jwbinfosysKeychain.removeAll()
        }
        if accountForZjuwlan == nil && !zjuwlanKeychain.allKeys().isEmpty {
            try! zjuwlanKeychain.removeAll()
        }
    }
    
    public static let sharedInstance = AccountManager()
    
    let groupDefaults = UserDefaults(suiteName: AppGroupIdentifier)!
        
    // MARK: - JWBInfoSys
    private let jwbinfosysKeychain = Keychain(server: "http://jwbinfosys.zju.edu.cn", protocolType: .http)
    private let JwbinfosysCurrentAccountKey = "JwbinfosysCurrentAccount"
    private let JwbinfosysSessionId = "JwbinfosysSessionId"
    private let JwbinfosysSessionKey = "JwbinfosysSessionKey"
    
    /**
     Add an account to JWBInfoSys and set it to current account.
     */
    func addAccountToJwbinfosys(_ username: String, _ password: String) {
        jwbinfosysKeychain[username] = password
        currentAccountForJwbinfosys = username
    }
    
    /**
     Remove an account from JWBInfoSys. If current account is just the removed one, it will be changed to the first of remaining accounts (or nil).
     */
    func removeAccountFromJwbinfosys(_ username: String) {
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
            return groupDefaults.string(forKey: JwbinfosysCurrentAccountKey)
        }
        set {
            groupDefaults.set(newValue, forKey: JwbinfosysCurrentAccountKey)
            groupDefaults.synchronize()
        }
    }
    
    /// Get or set session id and key of JWBInfoSys. This property is represented as a tuple, either of which can be nil.
    var sessionForCurrentAccount: (id: String?, key: String?) {
        get {
            return (groupDefaults.string(forKey: JwbinfosysSessionId), groupDefaults.string(forKey: JwbinfosysSessionKey))
        }
        set {
            groupDefaults.set(newValue.id, forKey: JwbinfosysSessionId)
            groupDefaults.set(newValue.key, forKey: JwbinfosysSessionKey)
            groupDefaults.synchronize()
        }
    }
    
    /**
     Retrieve the password of the given account in JWBInfoSys.
     
     - parameter username: Username of the account.
     
     - returns: Password of the account or nil if username is not found.
     */
    public func passwordForJwbinfosys(_ username: String) -> String? {
        return jwbinfosysKeychain[username]
    }
    
    // MARK: - ZJUWLAN
    private let ZjuwlanAccountKey = "ZjuwlanAccount"
    private let zjuwlanKeychain = Keychain(server: "https://net.zju.edu.cn", protocolType: .https)
    
    /// Get or set username of ZJUWLAN. If so far there is no account, you will get nil.
    public var accountForZjuwlan: String? {
        get {
            return groupDefaults.string(forKey: ZjuwlanAccountKey)
        }
        set {
            if let account = accountForZjuwlan {
                zjuwlanKeychain[account] = nil
            }
            groupDefaults.set(newValue, forKey: ZjuwlanAccountKey)
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
