//
//  FileDetailsViewController.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/23.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class FileDetailsViewController: UITableViewController {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var localState: UILabel!
    @IBOutlet weak var cloudState: UILabel!
    @IBOutlet weak var operationDate: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var qrcode: UIImageView!
    
    var file: File!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        icon.image = FileRecognizer.getFileIcon(fileName: file.name)
        
        name.text = file.name
        
        code.text = "提取码：\(file.code)"
        
        password.text = "密码：\(file.password)"
        
        localState.text = "本地状态：已存储"
        
        if file.dueDate.compare(Date()) == .orderedDescending {
            cloudState.text = "云端状态：已存储"
            cloudState.textColor = UIColor.black
        } else {
            cloudState.text = "云端状态：已过期"
            cloudState.textColor = UIColor.red
        }
        
        operationDate.text = "操作时间：\(Date.dateToLongString(date: file.operationDate))"
        
        dueDate.text = "云端到期：\(Date.dateToLongString(date: file.dueDate))"
        
        qrcode.image = QRCodeGenerator.createImage(qrcode: "\(BoxURL)/-\(file.code)", size: qrcode.bounds.width)
        let longPressGestureRecognizerForSaveQRCode = UILongPressGestureRecognizer(target: self, action: #selector(saveQRCode(longPressGestureRecognizer:)))
        longPressGestureRecognizerForSaveQRCode.minimumPressDuration = 0.5
        longPressGestureRecognizerForSaveQRCode.allowableMovement = 100
        qrcode.isUserInteractionEnabled = true
        qrcode.addGestureRecognizer(longPressGestureRecognizerForSaveQRCode)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @objc func saveQRCode(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            UIImageWriteToSavedPhotosAlbum(qrcode.image!, self, #selector(imageSaveCompletion(image:didFinishSavingWithError:contextInfo:)), nil)
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
    
}
