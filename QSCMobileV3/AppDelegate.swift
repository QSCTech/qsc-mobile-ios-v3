//
//  AppDelegate.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-04-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
import BWWalkthrough
import QSCMobileKit
import WatchConnectivity

let groupDefaults = UserDefaults(suiteName: AppGroupIdentifier)!

let UMengAppKey = "572381bf67e58e07a7005095"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var allowsRotation = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MobClick.start(withAppkey: UMengAppKey)
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _  in }
        }
        UMessage.start(withAppkey: UMengAppKey, launchOptions: launchOptions)
        UMessage.registerForRemoteNotifications()
        UMessage.setLogEnabled(true)
        
        if groupDefaults.object(forKey: RefreshOnLaunchKey) == nil {
            groupDefaults.set(true, forKey: RefreshOnLaunchKey)
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
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        
        introduceNewVersion()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshErrorHandler), name: .refreshError, object: nil)
        
        UINavigationBar.appearance().tintColor = ColorCompatibility.QSCGray
 //       UINavigationBar.appearance().backgroundColor = ColorCompatibility.systemBackground
        
        return true
    }
    
    @objc func refreshErrorHandler(notification: Notification) {
        if let error = notification.userInfo?["error"] as? String {
            if error.contains("教务网通知") {
                let studentId = AccountManager.sharedInstance.currentAccountForJwbinfosys!
                if studentId.count < 10 { // Graduate student
                    SVProgressHUD.showError(withStatus: error)
                    return
                }
                SVProgressHUD.dismiss()
                let alertController = UIAlertController(title: "刷新失败", message: "教务网通知，需确认后才能刷新", preferredStyle: .alert)
                let goAction = UIAlertAction(title: "立即前往", style: .default) { action in
                    let bvc = BrowserViewController.builtin(website: .jwbinfosys)
                    bvc.webViewDidFinishLoadCallback = { webView in
                        webView.loadRequest(URLRequest(url: URL(string:"http://jwbinfosys.zju.edu.cn/xskbcx.aspx?xh=\(studentId)")!))
                        bvc.webViewDidFinishLoadCallback = nil
                    }
                    UIApplication.topViewController()?.present(bvc, animated: true)
                }
                let cancelAction = UIAlertAction(title: "下次再说", style: .cancel)
                alertController.addAction(goAction)
                alertController.addAction(cancelAction)
                UIApplication.topViewController()?.present(alertController, animated: true)
            } else {
                SVProgressHUD.showError(withStatus: error)
            }
        }
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let tabBarController = window!.rootViewController as! UITabBarController
        tabBarController.presentedViewController?.dismiss(animated: false)
        if let scheme = url.scheme {
            switch scheme {
            case "QSCMobile":
                let paths = url.pathComponents
                switch paths[1] {
                case "add":
                    tabBarController.selectedIndex = 1
                    let vc = (tabBarController.selectedViewController as! UINavigationController).viewControllers.first!
                    vc.performSegue(withIdentifier: "addEvent", sender: nil)
                    return true
                case "timetable":
                    tabBarController.selectedIndex = 3
                    if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
                        let vc = JwbinfosysLoginViewController()
                        tabBarController.selectedViewController!.present(vc, animated: true)
                    } else {
                        let vc = CurriculaViewController()
                        vc.hidesBottomBarWhenPushed = true
                        tabBarController.selectedViewController!.show(vc, sender: nil)
                    }
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
            case "file":
                tabBarController.selectedIndex = 3
                let navigationController = tabBarController.selectedViewController! as! UINavigationController
                if let boxViewController = navigationController.topViewController! as? BoxViewController {
                    boxViewController.uploadFromAppDelegate(url: url)
                } else {
                    let storyboard = UIStoryboard(name: "Box", bundle: nil)
                    let vc = storyboard.instantiateInitialViewController() as! BoxViewController
                    tabBarController.selectedViewController!.show(vc, sender: nil)
                    vc.uploadFromAppDelegate(url: url)
                }
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if groupDefaults.bool(forKey: RefreshOnLaunchKey) && AccountManager.sharedInstance.currentAccountForJwbinfosys != nil {
            let now = Date()
            if let date = groupDefaults.object(forKey: LastRefreshDateKey) as? Date, !Calendar.current.isDate(date, inSameDayAs: now) {
                MobileManager.sharedInstance.refreshAll {
                    groupDefaults.set(now, forKey: LastRefreshDateKey)
                    print("Daily refresh completed (last refresh: \(date))")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowsRotation {
            return .allButUpsideDown
        } else {
            return .portrait
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

extension AppDelegate: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[WC Session] Did become inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("[WC Session] Did deactivate")
        WCSession.default.activate()
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("[WC Session] Activation failed with error: \(error.localizedDescription)")
            return
        }
        print("[WC Session] Activated with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let date = message["date"] as? Date {
            print("[WC Session] Message received by iOS")
            let events = eventsForDate(date).filter { $0.end >= date }
            var result = [String:Any]()
            for event in events {
                let name = event.name
                var time = ""
                if event.duration == .partialTime {
                    if Calendar.current.isDate(event.start, inSameDayAs: event.end) {
                        time = "\(event.start.stringOfTime) ～ \(event.end.stringOfTime)"
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
                        dateFormatter.dateFormat = "MM-dd hh:mm"
                        time = "\(dateFormatter.string(from: event.start)) ～ \(dateFormatter.string(from: event.end))"
                    }
                } else {
                    if event.end.timeIntervalSince(event.start) == 86400 {
                        time = "全天"
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
                        dateFormatter.dateFormat = "MM-dd"
                        time = "\(dateFormatter.string(from: event.start)) ～ \(dateFormatter.string(from: event.end))"
                    }
                }
                let place = event.place
                let color = QSCColor.category(event.category).cgColor.components!
                let singleEvent = ["name": name, "time": time, "place": place, "color": color] as [String : Any]
                result["\(result.count)"] = singleEvent
            }
            let reply = ["result": result]
            replyHandler(reply)
            print("[WC Session] Replied by iOS")
        }
    }
    
}

extension AppDelegate: BWWalkthroughViewControllerDelegate {
    
    func walkthroughCloseButtonPressed() {
        window?.rootViewController?.dismiss(animated: true)
    }
    
    func introduceNewVersion() {
        let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = storyboard.instantiateInitialViewController() as! BWWalkthroughViewController
        walkthrough.delegate = self
        
        let Build30032Key = "Build30032"
        if groupDefaults.object(forKey: Build30032Key) == nil {
            walkthrough.add(viewController: storyboard.instantiateViewController(withIdentifier: "AppleWatch"))
            groupDefaults.set(true, forKey: Build30032Key)
        }
        
        if walkthrough.numberOfPages > 0 {
            delay(1) { self.window?.rootViewController?.present(walkthrough, animated: true) }
        }
    }
    
}

// Adapted from https://gist.github.com/snikch/3661188
extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
