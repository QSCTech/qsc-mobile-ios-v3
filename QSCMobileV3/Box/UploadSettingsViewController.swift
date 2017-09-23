//
//  UploadSettingsViewController.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/23.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class UploadSettingsViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var expire: UISegmentedControl!
    @IBOutlet weak var qrcode: UIImageView!
    @IBOutlet weak var encryption: UISwitch!
    @IBOutlet weak var copyButton: UIButton!
    
    var file: File!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        code.text = file.code
        code.placeholder = file.code
        code.delegate = self
        code.addTarget(self, action: #selector(codeTextFieldChanged), for: .editingChanged)
        
        password.delegate = self
        
        qrcode.image = QRCodeGenerator.createImage(qrcode: "\(BoxURL)/-\(file.code)", size: qrcode.bounds.width)
        
        let longPressGestureRecognizerForSaveQRCode = UILongPressGestureRecognizer(target: self, action: #selector(saveQRCode(longPressGestureRecognizer:)))
        longPressGestureRecognizerForSaveQRCode.minimumPressDuration = 0.5
        longPressGestureRecognizerForSaveQRCode.allowableMovement = 100
        qrcode.isUserInteractionEnabled = true
        qrcode.addGestureRecognizer(longPressGestureRecognizerForSaveQRCode)
    }
    
    @IBAction func backBarButtonTapped(_ sender: UIBarButtonItem) {
        if code.text! == file.code {
            dismiss(animated: true)
        } else {
            let alertController = UIAlertController(title: "Box", message: "检测到上传设定变化且尚未提交，是否仍要返回？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "是", style: .destructive) { action in
                self.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "否", style: .default)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }
    
    @IBAction func submitBarButtonTapped(_ sender: UIBarButtonItem) {
        let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
        let expiration = Date.expirationsInSeconds[expire.selectedSegmentIndex]
        if encryption.isOn {
            BoxAPI.sharedInstance.set(fileURL: fileURL, oldcode: file.code, newcode: code.text!, password: password.text, secid: file.secid, expiration: expiration, callback: setCallBack)
        } else {
            BoxAPI.sharedInstance.set(fileURL: fileURL, oldcode: file.code, newcode: code.text!, password: nil, secid: file.secid, expiration: expiration, callback: setCallBack)
        }
    }
    
    
    @IBAction func copyButtonTapped() {
        code.resignFirstResponder()
        password.resignFirstResponder()
        UIPasteboard.general.string = code.text!
        let alert = UIAlertController(title: "Box", message: "提取码复制成功", preferredStyle: .alert)
        let action = UIAlertAction(title: "好", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
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
    
    @objc func codeTextFieldChanged(textField: UITextField) {
        if code.text!.isEmpty {
            copyButton.alpha = 0.4
            copyButton.isEnabled = false
        } else {
            copyButton.alpha = 1.0
            copyButton.isEnabled = true
        }
    }
    
    @objc func saveQRCode(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            if code.text! == file.code {
                UIImageWriteToSavedPhotosAlbum(qrcode.image!, self, #selector(imageSaveCompletion(image:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                let alert = UIAlertController(title: "Box", message: "检测到上传设定变化且尚未提交，请先提交修改再前往文件详情保存二维码", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func imageSaveCompletion(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        let alert: UIAlertController!
        if error == nil {
            alert = UIAlertController(title: "Box", message: "二维码保存成功", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Box", message: "二维码保存失败", preferredStyle: .alert)
        }
        let action = UIAlertAction(title: "好", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func setCallBack(fileURL: URL, state: String, parameter: Any?) {
        switch state {
        case "Fail":
            let message = parameter as! String
            let alert = UIAlertController(title: "Box", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
        case "Code":
            file.code = parameter as! String
        case "Password":
            file.password = parameter as! String
        case "Expiration":
            let expiration = parameter as! TimeInterval
            file.dueDate = file.operationDate.addingTimeInterval(expiration)
        case "Success":
            dismiss(animated: true)
        default:
            break
        }
        BoxManager.sharedInstance.saveFiles()
    }
    
}
