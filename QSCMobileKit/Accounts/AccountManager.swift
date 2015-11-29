//
//  AccountManager.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-29.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import KeychainAccess

class AccountManager: NSObject {
    
    /// Return the shared account manager.
    let sharedInstance = AccountManager()
    
    // MARK: - JWBInfoSys
    let JwbinfosysCurrentAccountKey = "JwbinfosysCurrentAccount"
    let jwbinfosysKeychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier! + ".jwbinfosys")
    
    /**
     Add an account to JWBInfoSys. If this account already exists, its password would be updated.
     
     - parameter username: Username of the account.
     - parameter password: Password of the account.
     */
    func addAccountToJwbinfosys(username: String, password: String) {
        jwbinfosysKeychain[username] = password
    }
    
    /**
     Remove an account from JWBInfoSys.
     
     - parameter username: Username of the account.
     */
    func removeAccountFromJwbinfosys(username: String) {
        jwbinfosysKeychain[username] = nil
    }
    
    /// Retrive all stored accounts of JWBInfoSys.
    var allAccountsForJwbinfosys: [String] {
        return jwbinfosysKeychain.allKeys()
    }
    
    /// Get or set current account of JWBInfosys.
    var currentAccountForJwbinfosys: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(JwbinfosysCurrentAccountKey)!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: JwbinfosysCurrentAccountKey)
        }
    }
    
    /**
     Retrive the password of the given account in JWBInfoSys.
     
     - parameter username: Username of the account.
     
     - returns: Password of the account.
     */
    func passwordForJwbinfosys(username: String) -> String {
        return jwbinfosysKeychain[username]!
    }
    
    // MARK: - ZJUWLAN
    let ZjuwlanAccountKey = "ZjuwlanAccount"
    let zjuwlanKeychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier! + ".zjuwlan")
    
    /// Get or set username of ZJUWLAN.
    var accountForZjuwlan: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(ZjuwlanAccountKey)!
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: ZjuwlanAccountKey)
        }
    }
    
    /// Get or set password of ZJUWLAN.
    var passwordForZjuwlan: String {
        get {
            return zjuwlanKeychain[accountForZjuwlan]!
        }
        set {
            zjuwlanKeychain[accountForZjuwlan] = newValue
        }
    }

}
