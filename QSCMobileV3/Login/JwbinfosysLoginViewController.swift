//
//  JwbinfosysLoginViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import MBProgressHUD
import QSCMobileKit

class JwbinfosysLoginViewController: UIViewController {

    init() {
        super.init(nibName: "JwbinfosysLoginViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        navigationItem.title = "教务网账号"
    }

    @IBAction func login(sender: AnyObject) {
        if !usernameField.text!.isValidSid {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.mode = .CustomView
            hud.customView = UIImageView(image: UIImage(named: "Cross"))
            hud.labelText = "学号格式不正确"
            delayOneSecond {
                hud.hide(true)
            }
            return
        }
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        MobileManager.sharedInstance.loginValidate(usernameField.text!, passwordField.text!) { success, error in
            if success {
                MobileManager.sharedInstance.refreshAll {
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "Check"))
                    hud.labelText = "账号登录成功"
                    delayOneSecond {
                        hud.hide(true)
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                }
            } else {
                hud.mode = .CustomView
                hud.customView = UIImageView(image: UIImage(named: "Cross"))
                hud.labelText = error
                delayOneSecond {
                    hud.hide(true)
                }
            }
        }
    }
    
}
