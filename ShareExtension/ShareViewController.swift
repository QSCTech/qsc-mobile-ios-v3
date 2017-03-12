//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Zzh on 2017/2/24.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class ShareViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    var file: File!
    var filePaths: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAttachments() { error in
            if error != nil {
                let alertController = UIAlertController(title: "提示", message: "获取附件错误", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好", style: .default) { action in
                    self.cancelRequest(error: error!)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
            } else {
                self.label.text = "共 \(self.filePaths.count) 个文件正在上传"
                self.upload()
            }
        }
    }
    
    @IBAction func cancelButtonTapped() {
        if file != nil {
            BoxManager.sharedInstance.removeFile(file: file)
        }
        completeRequest()
    }
    
    // MARK: - Upload
    
    func upload() {
        file = BoxManager.sharedInstance.newFile()
        file.name = "\(file.directory).zip"
        file.state = "正在上传"
        BoxManager.sharedInstance.createZip(file: file, withFilesAtPaths: filePaths)
        BoxManager.sharedInstance.saveFiles()
        let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
        BoxAPI.sharedInstance.upload(fileURL: fileURL, callback: uploadCallBack)
    }
    
    // MARK: - Upload CallBack
    
    func uploadCallBack(fileURL: URL, state: String, parameter: Any?) {
        if let file = BoxManager.sharedInstance.getFileByFileURL(fileURL) {
            switch state {
            case "Progress":
                file.progress = NSNumber(value: parameter as! Double)
                progress.setProgress(Float(file.progress), animated: true)
            case "Code":
                file.code = parameter as! String
            case "Secid":
                file.secid = parameter as! String
            case "Fail":
                file.state = "上传失败"
                view.isHidden = true
                let message = parameter as! String
                let alert = UIAlertController(title: "Box", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default) { action in
                    self.completeRequest()
                }
                alert.addAction(action)
                self.present(alert, animated: true)
            case "Success":
                file.progress = NSNumber(value: 1)
                progress.setProgress(Float(file.progress), animated: true)
                file.state = "已上传"
                view.isHidden = true
                let alertController = UIAlertController(title: "上传成功", message: "文件提取码：\(file.code)\n详细信息请于求是潮 App 内查看", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .cancel) { action in
                    self.completeRequest()
                }
                let settingAction = UIAlertAction(title: "高级设置", style: .default) { action in
                    self.performSegue(withIdentifier: "showUploadSettings", sender: file)
                }
                alertController.addAction(settingAction)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            default:
                break
            }
            BoxManager.sharedInstance.saveFiles()
        }
    }
    
    // MARK: - Segue for Upload Settings
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUploadSettings" {
            let uploadSettingsViewController = segue.destination as! UploadSettingsViewController
            uploadSettingsViewController.file = sender as! File
        }
    }
    
    @IBAction func unwind(sender: UIStoryboardSegue) {
        completeRequest()
    }
    
    // MARK: - Extension Context
    
    func completeRequest() {
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func cancelRequest(error: Error) {
        extensionContext!.cancelRequest(withError: error)
    }
    
    func getAttachments(completionHandler: @escaping (Error?) -> ()) {
        var count = 0
        for inputItem in extensionContext!.inputItems as [AnyObject] {
            for attachment in inputItem.attachments as! [NSItemProvider] {
                count += 1
                attachment.loadItem(forTypeIdentifier: "public.data", options: nil) { data, error in
                    if error == nil {
                        let url = data as! URL
                        self.filePaths.append(url.path)
                        if self.filePaths.count == count {
                            completionHandler(nil)
                        }
                    } else {
                        completionHandler(error)
                        return
                    }
                }
            }
        }
    }
    
}
