//
//  AppDelegate.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-04-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import QSCMobileKit

let UMengAppKey = "572381bf67e58e07a7005095"

let groupDefaults = UserDefaults(suiteName: AppGroupIdentifier)!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        MobClick.start(withAppkey: UMengAppKey)
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .badge, .sound]) { _ in }
        }
        UMessage.start(withAppkey: UMengAppKey, launchOptions: launchOptions)
        UMessage.registerForRemoteNotifications()
        UMessage.setLogEnabled(true)
        
        if groupDefaults.object(forKey: RefreshOnLaunchKey) == nil {
            groupDefaults.set(true, forKey: RefreshOnLaunchKey)
        }
        if groupDefaults.bool(forKey: RefreshOnLaunchKey) && AccountManager.sharedInstance.currentAccountForJwbinfosys != nil {
            MobileManager.sharedInstance.refreshAll(errorBlock: { _ in }, callback: {
                print("Refresh on launch completed")
            })
        }
        if groupDefaults.object(forKey: ShowScoreKey) == nil {
            groupDefaults.set(true, forKey: ShowScoreKey)
        }
        if groupDefaults.object(forKey: CampusFromIndexKey) == nil {
            // 0 stands for 紫金港
            groupDefaults.set(0, forKey: CampusFromIndexKey)
        }
        if groupDefaults.object(forKey: CampusToIndexKey) == nil {
            // 1 stands for 玉泉
            groupDefaults.set(1, forKey: CampusToIndexKey)
        }
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.toHexString()
        groupDefaults.set(deviceToken, forKey: DeviceTokenKey)
        if let account = AccountManager.sharedInstance.currentAccountForJwbinfosys {
            let url = "https://ios.zjuqsc.com/kv"
            let params = ["sid": account, "token": deviceToken]
            _ = Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let tabBarController = window!.rootViewController as! UITabBarController
        tabBarController.presentedViewController?.dismiss(animated: false, completion: nil)
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
            tabBarController.present(JwbinfosysLoginViewController(), animated: true, completion: nil)
        } else {
            tabBarController.selectedIndex = 3
            switch shortcutItem.type {
            case "Course", "Exam":
                let storyboard = UIStoryboard(name: "QueryList", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! SemesterListViewController
                vc.source = shortcutItem.type == "Course" ? .course : .exam
                (tabBarController.selectedViewController as! UINavigationController).show(vc, sender: nil)
            case "Bus":
                tabBarController.present(BusViewController(), animated: true, completion: nil)
            default:
                break
            }
        }
        completionHandler(true)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let path = url.pathComponents
        let tabBarController = window!.rootViewController as! UITabBarController
        tabBarController.presentedViewController?.dismiss(animated: false, completion: nil)
        let events = eventsForDate(Date())
        switch path[1] {
        case "add":
            tabBarController.selectedIndex = 1
            let vc = (tabBarController.selectedViewController as! UINavigationController).topViewController!
            vc.performSegue(withIdentifier: "addEvent", sender: vc)
            return true
        case "timetable":
            tabBarController.selectedIndex = 3
            (tabBarController.selectedViewController as! UINavigationController).topViewController!.show(CurriculaViewController(), sender: nil)
            return true
        case "detail":
            let recievedEvent = events[Int(path[2])!]
            tabBarController.selectedIndex = 1
            let vc = (tabBarController.selectedViewController as! UINavigationController).topViewController as! CalendarViewController
            vc.selectedEvent = recievedEvent
            vc.selectedDate = Date()
            if vc.selectedEvent.category == .course || vc.selectedEvent.category == .exam {
                vc.performSegue(withIdentifier: "showCourseDetail", sender: vc)
            } else {
                vc.performSegue(withIdentifier: "showEventDetail", sender: vc)
            }
            return true
        default:
            return false
        }
    }
    
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.trigger is UNPushNotificationTrigger {
            UMessage.didReceiveRemoteNotification(notification.request.content.userInfo)
        }
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.trigger is UNPushNotificationTrigger {
            UMessage.didReceiveRemoteNotification(response.notification.request.content.userInfo)
        }
        completionHandler()
    }
    
}
