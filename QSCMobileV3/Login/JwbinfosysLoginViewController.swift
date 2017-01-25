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
        super.init(nibName: "JwbinfosysLoginViewController", bundle: Bundle.main)
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
    
    @IBAction func login(_ sender: AnyObject) {
        SVProgressHUD.show(withStatus: "登录中")
        MobileManager.sharedInstance.loginValidate(usernameField.text!, passwordField.text!, errorBlock: { notification in
            SVProgressHUD.show(withStatus: notification.userInfo?["error"] as? String ?? "")
        }, callback: { success, error in
            if success {
                self.dismiss(animated: true)
                SVProgressHUD.showSuccess(withStatus: "登录成功")
            } else {
                SVProgressHUD.showError(withStatus: error)
            }
        })
    }
    
    @IBAction func textFieldDidChange(_ sender: AnyObject) {
        let isValid = usernameField.text!.isValidSid && !passwordField.text!.isEmpty
        if isValid {
            loginButton.isEnabled = true
            loginButton.alpha = 1
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
}

extension JwbinfosysLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login(textField)
        return false
    }
    
}
