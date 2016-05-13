//
//  AppDelegate.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-04-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

let UMengAppKey = "572381bf67e58e07a7005095"
let RefreshOnLaunchKey = "RefreshOnLaunch"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        MobClick.startWithAppkey(UMengAppKey)
        UMessage.startWithAppkey(UMengAppKey, launchOptions: launchOptions)
        UMessage.registerRemoteNotificationAndUserNotificationSettings(notificationSettings)
        
        if groupDefaults.objectForKey(RefreshOnLaunchKey) == nil {
            groupDefaults.setObject(true, forKey: RefreshOnLaunchKey)
        }
        if groupDefaults.objectForKey(RefreshOnLaunchKey) as! Bool && AccountManager.sharedInstance.currentAccountForJwbinfosys != nil{
            MobileManager.sharedInstance.refreshAll {
                // TODO: Post a notification to force views to refresh.
                print("Refresh on launch completed")
            }
        }
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        UMessage.registerDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
    var notificationSettings: UIUserNotificationSettings {
        return UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: [])
    }

}
