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
    
    let mobileManager = MobileManager.sharedInstance
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.scrollsToTop = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.removeAllSubviews()
        let events = eventsForDate(NSDate()).filter { $0.category != .Todo && $0.end >= NSDate() }
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
    }
    
    @IBAction func pageDidChange(sender: UIPageControl) {
        var frame = scrollView.frame
        frame.origin.x = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
}

extension MomentViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = scrollView.frame.width
        pageControl.currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
    }
    
}
