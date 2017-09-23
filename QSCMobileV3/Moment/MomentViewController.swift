//
//  MomentViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class MomentViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
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
}

extension MomentViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        pageControl.currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        updateCurrentEvent()
    }
    
}
