//
//  AppDelegate.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-04-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
import QSCMobileKit

let UMengAppKey = "572381bf67e58e07a7005095"

let groupDefaults = NSUserDefaults(suiteName: AppGroupIdentifier)!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        MobClick.startWithAppkey(UMengAppKey)
        UMessage.startWithAppkey(UMengAppKey, launchOptions: launchOptions)
        UMessage.registerForRemoteNotifications()
        UMessage.setLogEnabled(true)
        
        if groupDefaults.objectForKey(RefreshOnLaunchKey) == nil {
            groupDefaults.setBool(true, forKey: RefreshOnLaunchKey)
        }
        if groupDefaults.boolForKey(RefreshOnLaunchKey) && AccountManager.sharedInstance.currentAccountForJwbinfosys != nil {
            MobileManager.sharedInstance.refreshAll({ _ in }, callback: {
                // TODO: Post a notification to force views to refresh.
                print("Refresh on launch completed")
            })
        }
        if groupDefaults.objectForKey(ShowScoreKey) == nil {
            groupDefaults.setBool(false, forKey: ShowScoreKey)
        }
        if groupDefaults.objectForKey(EventNotificationKey) == nil {
            // 0 means Never
            groupDefaults.setInteger(0, forKey: EventNotificationKey)
        }
        if groupDefaults.objectForKey(ShowAllCoursesKey) == nil {
            groupDefaults.setBool(false, forKey: ShowAllCoursesKey)
        }
        if groupDefaults.objectForKey(CampusFromIndexKey) == nil {
            // 0 stands for 紫金港
            groupDefaults.setInteger(0, forKey: CampusFromIndexKey)
        }
        if groupDefaults.objectForKey(CampusToIndexKey) == nil {
            // 1 stands for 玉泉
            groupDefaults.setInteger(1, forKey: CampusToIndexKey)
        }
        
        SVProgressHUD.setDefaultStyle(.Dark)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("[Device token] " + deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: ""))
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
}
