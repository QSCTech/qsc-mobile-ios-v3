//
//  UploadSettingsViewController.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/24.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class UploadSettingsViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var expire: UISegmentedControl!
    @IBOutlet weak var encryption: UISwitch!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tip: UILabel!
    
    var file: File!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        code.text = file.code
        code.placeholder = file.code
        code.delegate = self
        
        password.delegate = self
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        if code.text! == file.code {
            performSegue(withIdentifier: "unwindToShare", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Box", message: "检测到上传设定变化且尚未提交，是否仍要取消？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "是", style: .destructive, handler: {
                action in
                self.performSegue(withIdentifier: "unwindToShare", sender: nil)
            })
            let cancelAction = UIAlertAction(title: "否", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        submitButton.isEnabled = false
        let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
        let expiration = Date.expirationsInSeconds[expire.selectedSegmentIndex]
        if encryption.isOn {
            BoxAPI.sharedInstance.set(fileURL: fileURL, oldcode: file.code, newcode: code.text!, password: password.text, secid: file.secid, expiration: expiration, callback: setCallBack)
        } else {
            BoxAPI.sharedInstance.set(fileURL: fileURL, oldcode: file.code, newcode: code.text!, password: nil, secid: file.secid, expiration: expiration, callback: setCallBack)
        }
    }
    
    @IBAction func encryptionSwitchDidChange() {
        if encryption.isOn {
            password.isEnabled = true
            if expire.selectedSegmentIndex > 2 {
                expire.selectedSegmentIndex = 2
            }
            expire.setEnabled(false, forSegmentAt: 3)
            expire.setEnabled(false, forSegmentAt: 4)
        } else {
            password.isEnabled = false
            expire.setEnabled(true, forSegmentAt: 3)
            expire.setEnabled(true, forSegmentAt: 4)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setCallBack(fileURL: URL, state: String, parameter: Any?) {
        switch state {
        case "Fail":
            submitButton.isEnabled = true
            tip.text = parameter as? String
            tip.isHidden = false
        case "Code":
            file.code = parameter as! String
        case "Password":
            file.password = parameter as! String
        case "Expiration":
            let expiration = parameter as! TimeInterval
            file.dueDate = file.operationDate.addingTimeInterval(expiration)
        case "Success":
            submitButton.isEnabled = true
            let alert = UIAlertController(title: "设定成功", message: "文件提取码：\(file.code)\n二维码请于\"求是潮\"App 内查看", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default) { action in
                self.performSegue(withIdentifier: "unwindToShare", sender: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        default:
            break
        }
        BoxManager.sharedInstance.saveFiles()
    }

}
