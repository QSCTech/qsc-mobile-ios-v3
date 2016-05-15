//
//  ZjuwlanLoginViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import MBProgressHUD
import QSCMobileKit

class ZjuwlanLoginViewController: UIViewController {

    init() {
        super.init(nibName: "ZjuwlanLoginViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let accountManager = AccountManager.sharedInstance
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        navigationItem.title = "ZJUWLAN 账号"
        usernameField.text = accountManager.accountForZjuwlan
        passwordField.text = accountManager.passwordForZjuwlan
    }
    
    @IBAction func save(sender: AnyObject) {
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
        accountManager.accountForZjuwlan = usernameField.text
        accountManager.passwordForZjuwlan = passwordField.text
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .CustomView
        hud.customView = UIImageView(image: UIImage(named: "Check"))
        hud.labelText = "账号保存成功"
        delayOneSecond {
            hud.hide(true)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func remove(sender: AnyObject) {
        usernameField.text = nil
        passwordField.text = nil
        accountManager.accountForZjuwlan = nil
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .CustomView
        hud.customView = UIImageView(image: UIImage(named: "Check"))
        hud.labelText = "账号删除成功"
        delayOneSecond {
            hud.hide(true)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
}
