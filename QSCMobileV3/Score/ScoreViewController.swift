//
//  ScoreViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-30.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    init() {
        super.init(nibName: "ScoreViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
