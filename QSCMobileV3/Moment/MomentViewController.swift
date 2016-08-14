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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        loginButton.layer.cornerRadius = 18
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.removeAllSubviews()
        // TODO: Support all-day events and future exams
        let events = eventsForDate(NSDate()).filter { $0.duration == .PartialTime && $0.end >= NSDate() }
        pageControl.numberOfPages = events.count
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(events.count), height: scrollView.frame.height)
        for (index, event) in events.enumerate() {
            let vc = MomentPageViewController(event: event)
            var frame = scrollView.frame
            frame.origin.x = scrollView.frame.width * CGFloat(index)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
        }
        if events.isEmpty {
            let vc = MomentPageViewController(event: nil)
            vc.view.frame = scrollView.frame
            scrollView.addSubview(vc.view)
        }
        
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil && events.isEmpty {
            loginButton.hidden = false
        } else {
            loginButton.hidden = true
        }
    }
    
    @IBAction func pageDidChange(sender: UIPageControl) {
        var frame = scrollView.frame
        frame.origin.x = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func login(sender: AnyObject) {
        let vc = JwbinfosysLoginViewController()
        presentViewController(vc, animated: true, completion: nil)
    }
}

extension MomentViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = scrollView.frame.width
        pageControl.currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
    }
    
}
