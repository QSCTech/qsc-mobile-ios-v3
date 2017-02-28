//
//  AppDelegate.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-04-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
import EAIntroView
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
        if groupDefaults.object(forKey: AuxiliaryScoreKey) == nil {
            groupDefaults.set(0, forKey: AuxiliaryScoreKey)
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
        
        let Build30020Key = "Build30020"
        if groupDefaults.object(forKey: Build30020Key) == nil {
            let view = window!.rootViewController!.view!
            let introPage = EAIntroPage()
            introPage.bgImage = UIImage(named: "TodayWidget")
            let introView = EAIntroView(frame: view.bounds, andPages: [introPage])
            introView?.skipButtonY = view.bounds.height - 20
            introView?.show(in: view)
            groupDefaults.set(true, forKey: Build30020Key)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.toHexString()
        groupDefaults.set(deviceToken, forKey: DeviceTokenKey)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let tabBarController = window!.rootViewController as! UITabBarController
        tabBarController.presentedViewController?.dismiss(animated: false)
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
            tabBarController.present(JwbinfosysLoginViewController(), animated: true)
        } else {
            tabBarController.selectedIndex = 3
            switch shortcutItem.type {
            case "Course", "Exam":
                let storyboard = UIStoryboard(name: "QueryList", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! SemesterListViewController
                vc.source = shortcutItem.type == "Course" ? .course : .exam
                tabBarController.selectedViewController?.show(vc, sender: nil)
            case "Bus":
                tabBarController.present(BusViewController(), animated: true)
            default:
                break
            }
        }
        completionHandler(true)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let paths = url.pathComponents
        let tabBarController = window!.rootViewController as! UITabBarController
        tabBarController.presentedViewController?.dismiss(animated: false)
        switch paths[1] {
        case "add":
            tabBarController.selectedIndex = 1
            let vc = (tabBarController.selectedViewController as! UINavigationController).viewControllers.first!
            vc.performSegue(withIdentifier: "addEvent", sender: nil)
            return true
        case "timetable":
            tabBarController.selectedIndex = 3
            tabBarController.selectedViewController!.show(CurriculaViewController(), sender: nil)
            return true
        case "detail":
            let event = eventsForDate(Date())[Int(paths[2])!]
            tabBarController.selectedIndex = 1
            let vc = (tabBarController.selectedViewController as! UINavigationController).viewControllers.first as! CalendarViewController
            vc.selectedEvent = event
            vc.selectedDate = Date()
            if vc.selectedEvent.category == .course || vc.selectedEvent.category == .exam {
                vc.performSegue(withIdentifier: "showCourseDetail", sender: nil)
            } else {
                vc.performSegue(withIdentifier: "showEventDetail", sender: nil)
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
