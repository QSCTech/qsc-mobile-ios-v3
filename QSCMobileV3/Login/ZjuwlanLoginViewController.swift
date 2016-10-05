//
//  ZjuwlanLoginViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
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
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ZJUWLAN"
        saveButton.layer.cornerRadius = 5
        usernameField.text = accountManager.accountForZjuwlan
        passwordField.text = accountManager.passwordForZjuwlan
    }
    
    @IBAction func save(sender: AnyObject) {
        view.endEditing(true)
        accountManager.accountForZjuwlan = usernameField.text
        accountManager.passwordForZjuwlan = passwordField.text
        self.navigationController?.popViewControllerAnimated(true)
        SVProgressHUD.showSuccessWithStatus("账号保存成功")
    }
    
    @IBAction func remove(sender: AnyObject) {
        usernameField.text = ""
        passwordField.text = ""
        accountManager.accountForZjuwlan = nil
        self.navigationController?.popViewControllerAnimated(true)
        SVProgressHUD.showSuccessWithStatus("账号删除成功")
    }
    
    @IBAction func textFieldDidChange(sender: AnyObject) {
        if !usernameField.text!.isEmpty && !passwordField.text!.isEmpty {
            saveButton.enabled = true
            saveButton.alpha = 1
        } else {
            saveButton.enabled = false
            saveButton.alpha = 0.5
        }
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
}
