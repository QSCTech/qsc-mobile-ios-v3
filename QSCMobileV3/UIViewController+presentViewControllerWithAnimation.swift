//
//  UIViewController+presentViewControllerWithAnimation.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-11.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentViewControllerWithAnimation(viewControllerToPresent: UIViewController) {
        let animation = CATransition()
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromRight
        view.window!.layer.addAnimation(animation, forKey: nil)
        
        presentViewController(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissViewControllerWithAnimation() {
        let animation = CATransition()
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromLeft
        view.window!.layer.addAnimation(animation, forKey: nil)
        
        dismissViewControllerAnimated(false, completion: nil)
    }
    
}
