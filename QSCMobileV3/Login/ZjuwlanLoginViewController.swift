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
        super.init(nibName: "ZjuwlanLoginViewController", bundle: Bundle.main)
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
    
    @IBAction func save(_ sender: AnyObject) {
        view.endEditing(true)
        accountManager.accountForZjuwlan = usernameField.text
        accountManager.passwordForZjuwlan = passwordField.text
        _ = self.navigationController?.popViewController(animated: true)
        SVProgressHUD.showSuccess(withStatus: "账号保存成功")
    }
    
    @IBAction func remove(_ sender: AnyObject) {
        usernameField.text = ""
        passwordField.text = ""
        accountManager.accountForZjuwlan = nil
        _ = self.navigationController?.popViewController(animated: true)
        SVProgressHUD.showSuccess(withStatus: "账号删除成功")
    }
    
    @IBAction func textFieldDidChange(_ sender: AnyObject) {
        if !usernameField.text!.isEmpty && !passwordField.text!.isEmpty {
            saveButton.isEnabled = true
            saveButton.alpha = 1
        } else {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
}
