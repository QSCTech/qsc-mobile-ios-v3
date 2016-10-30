//
//  JwbinfosysLoginViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-15.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SVProgressHUD
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
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.delegate = self
        navigationItem.title = "教务网账号"
        loginButton.layer.cornerRadius = 5
    }
    
    @IBAction func login(sender: AnyObject) {
        SVProgressHUD.showWithStatus("登录中")
        MobileManager.sharedInstance.loginValidate(usernameField.text!, passwordField.text!) { success, error in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
                SVProgressHUD.showSuccessWithStatus("登录成功")
            } else {
                SVProgressHUD.showErrorWithStatus(error)
            }
        }
    }
    
    @IBAction func textFieldDidChange(sender: AnyObject) {
        let isValid = usernameField.text!.isValidSid && !passwordField.text!.isEmpty
        if isValid {
            loginButton.enabled = true
            loginButton.alpha = 1
        } else {
            loginButton.enabled = false
            loginButton.alpha = 0.5
        }
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension JwbinfosysLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        login(textField)
        return false
    }
    
}
