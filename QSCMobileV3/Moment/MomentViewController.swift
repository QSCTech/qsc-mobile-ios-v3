//
//  MomentViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit
import SVProgressHUD

class MomentViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    let accountManager = AccountManager.sharedInstance
    
    var events = [Event]()
    var pageControllers = [MomentPageViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        automaticallyAdjustsScrollViewInsets = false
        
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        loginButton.layer.cornerRadius = 18
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
        
        let viewAppear = { (_: Notification) in
            self.viewWillAppear(false)
            self.viewDidAppear(false)
        }
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main, using: viewAppear)
        NotificationCenter.default.addObserver(forName: .refreshCompleted, object: nil, queue: .main, using: viewAppear)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        events = eventsForDate(Date()).filter { $0.end >= Date() }
        if AccountManager.sharedInstance.currentAccountForJwbinfosys != nil {
            events += MobileManager.sharedInstance.comingExams
        }
        pageControl.numberOfPages = events.count
        
        pageControllers.removeAll()
        for event in events {
            let vc = MomentPageViewController(event: event)
            vc.momentViewController = self
            pageControllers.append(vc)
        }
        if events.isEmpty {
            let vc = MomentPageViewController(event: nil)
            pageControllers.append(vc)
            
            stackView.isHidden = true
            navigationItem.title = "今日无事"
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        } else {
            stackView.isHidden = false
            updateCurrentEvent()
        }
        
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil && events.isEmpty {
            loginButton.isHidden = false
        } else {
            loginButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.removeAllSubviews()
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        scrollView.contentSize = CGSize(width: width * CGFloat(pageControllers.count), height: height)
        for (index, vc) in pageControllers.enumerated() {
            vc.view.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
            scrollView.addSubview(vc.view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = nil
    }
    
    func updateCurrentEvent() {
        if events.isEmpty {
            return
        }
        
        let event = events[pageControl.currentPage]
        navigationItem.title = event.name
        timeLabel.text = event.time
        placeLabel.text = event.place
        
        let color = QSCColor.categoría(event.category)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color]
        timeLabel.textColor = color
        placeLabel.textColor = color
    }
    
    @IBAction func pageDidChange(_ sender: UIPageControl) {
        let x = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        updateCurrentEvent()
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let vc = JwbinfosysLoginViewController()
        present(vc, animated: true)
    }
    
    @IBAction func refresh(_ sender: Any) {
        if accountManager.currentAccountForJwbinfosys != nil {
            refreshButton.isEnabled = false
            SVProgressHUD.show(withStatus: "刷新中")
            var result = " "
            MobileManager.sharedInstance.refreshAll(errorBlock: { notification in
                if let error = notification.userInfo?["error"] as? String {
                    result = error
                    if error != "教务网通知，请登录网站查收" {
                        SVProgressHUD.showError(withStatus: error)
                    } else {
                        SVProgressHUD.dismiss()
                        let alertController = UIAlertController(title: "刷新失败", message: "教务网有新通知，需查收后才能刷新", preferredStyle: .alert)
                        let goAction = UIAlertAction(title: "立即前往", style: .default) { action in
                            let url = URL(string: "http://jwbinfosys.zju.edu.cn/default2.aspx")!
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            let username = self.accountManager.currentAccountForJwbinfosys!.percentEncoded
                            let password = self.accountManager.passwordForJwbinfosys(username)!.percentEncoded
                            request.httpBody = "__EVENTTARGET=Button1&__EVENTARGUMENT=&__VIEWSTATE=dDwxNTc0MzA5MTU4Ozs%2Bb5wKASjiu%2BfSjITNzcKuKXEUyXg%3D&TextBox1=\(username)&TextBox2=\(password)&RadioButtonList1=%D1%A7%C9%FA&Text1=".data(using: String.Encoding.ascii)
                            let bvc = BrowserViewController(request: request)
                            bvc.webViewDidFinishLoadCallBack = { webView in
                                bvc.webViewDidFinishLoadCallBack = nil
                                webView.loadRequest(URLRequest(url: URL(string:"http://jwbinfosys.zju.edu.cn/xskbcx.aspx?xh=\(username)")!))
                            }
                            self.present(bvc, animated: true)
                        }
                        let cancelAction = UIAlertAction(title: "下次再说", style: .cancel)
                        alertController.addAction(goAction)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true)
                    }
                } else {
                    result = ""
                }
                
            }, callback: {
                if result == " " {
                    SVProgressHUD.showSuccess(withStatus: "刷新成功")
                }
                self.refreshButton.isEnabled = true
            })
        } else {
            SVProgressHUD.showError(withStatus: "请先登录")
        }
    }
    
}

extension MomentViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        pageControl.currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        updateCurrentEvent()
    }
    
}
