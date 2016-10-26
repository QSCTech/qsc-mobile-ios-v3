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
        loginButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).CGColor
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewWillAppear), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewDidAppear), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserverForName("RefreshAll", object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.viewWillAppear(false)
            self.viewDidAppear(false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Support all-day events and future exams
        events = eventsForDate(NSDate()).filter { $0.duration == .PartialTime && $0.end >= NSDate() }
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
            
            stackView.hidden = true
            navigationItem.title = "今日无事"
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        } else {
            stackView.hidden = false
            updateCurrentEvent()
        }
        
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil && events.isEmpty {
            loginButton.hidden = false
        } else {
            loginButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.removeAllSubviews()
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        scrollView.contentSize = CGSize(width: width * CGFloat(pageControllers.count), height: height)
        for (index, vc) in pageControllers.enumerate() {
            vc.view.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
            scrollView.addSubview(vc.view)
        }
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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: color]
        timeLabel.textColor = color
        placeLabel.textColor = color
    }
    
    @IBAction func pageDidChange(sender: UIPageControl) {
        let x = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        updateCurrentEvent()
    }
    
    @IBAction func login(sender: AnyObject) {
        let vc = JwbinfosysLoginViewController()
        presentViewController(vc, animated: true, completion: nil)
    }
}

extension MomentViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = scrollView.frame.width
        pageControl.currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        updateCurrentEvent()
    }
    
}
