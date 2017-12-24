//
//  BoxViewController.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class BoxViewController: UIViewController {
    
    var files = BoxManager.sharedInstance.allFiles
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noFileImageView: UIImageView!
    @IBOutlet weak var downloadBarButton: UIBarButtonItem!
    @IBOutlet weak var uploadButton: UIButton!
    
    var downloadDropDownMenu: DropDownMenuView!
    var downloadMultiSelectView: MultiSelectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadBarButton.image = UIImage(named: "Download")?.withRenderingMode(.alwaysOriginal)
        downloadMultiSelectView = MultiSelectView(superView: view, title: "选择文件",width: 250, height: 218, offsetY: -10, shadow: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        files = BoxManager.sharedInstance.allFiles
        tableView.reloadData()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBAction func downloadBarButtonTapped(_ sender: UIBarButtonItem) {
        if downloadDropDownMenu != nil && downloadDropDownMenu.isHidden == true {
            downloadDropDownMenu.removeFromSuperview()
            downloadDropDownMenu = nil
        }
        if downloadDropDownMenu == nil {
            downloadDropDownMenu = DropDownMenuView(items: [["text": "提取码", "icon": "InputCode"], ["text": "扫一扫", "icon": "ScanQRCode"]], superView: view, width: 122, pointerX: view.frame.width - 37.5, pointerY: 0, menuX: view.frame.width - 130, shadow: true)
            downloadDropDownMenu.selectCallBack = downloadDropDownMenuCallBack
            downloadDropDownMenu.isHidden = false
        } else {
            downloadDropDownMenu.removeFromSuperview()
            downloadDropDownMenu = nil
        }
    }
    
    func downloadDropDownMenuCallBack(index: Int) {
        switch index {
        case 0:
            let alertController = UIAlertController(title: "文件下载", message: nil, preferredStyle: .alert)
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "请输入提取码"
                textField.adjustsFontSizeToFitWidth = false
                textField.minimumFontSize = 14
                textField.returnKeyType = UIReturnKeyType.done
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.clearButtonMode = .whileEditing
                textField.delegate = self
                textField.tag = -1
                textField.addTarget(self, action: #selector(self.textFieldChanged(textField:)), for: .editingChanged)
            }
            let okAction = UIAlertAction(title: "确定", style: .default) { action in
                let code = alertController.textFields!.first!.text!
                self.download(code: code)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            okAction.isEnabled = false
            present(alertController, animated: true)
        case 1:
            let qrcodeScannerViewController = QRCodeScannerViewController()
            present(qrcodeScannerViewController, animated: true)
            qrcodeScannerViewController.callback = { qrcode in
                if qrcode.hasPrefix("\(BoxURL)/-") {
                    let code = String(qrcode[qrcode.index(qrcode.startIndex, offsetBy: 24)...])
                    self.perform(#selector(self.download(code:)), with: code, afterDelay: 1)
                } else {
                    let alert = UIAlertController(title: "Box", message: "非求是潮 Box 二维码", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            }
        default:
            break
        }
    }
    
    @IBAction func uploadButtonTapped() {
        let uploadalertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let canceluploadAction = UIAlertAction(title: "取消", style: .cancel)
        uploadalertController.addAction(canceluploadAction)
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { action in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            imagePickerController.navigationItem.prompt = "Upload from Camera"
            self.present(imagePickerController, animated: true)
        }
        uploadalertController.addAction(cameraAction)
        let photoPickerAction = UIAlertAction(title: "相册", style: .default) { action in
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.navigationItem.prompt = "Upload from PhotoLibrary"
            self.present(imagePickerController, animated: true)
        }
        uploadalertController.addAction(photoPickerAction)
        let iCloudDriveAction = UIAlertAction(title: "iCloud Drive", style: .default) { action in
            if FileManager().url(forUbiquityContainerIdentifier: nil) != nil {
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true)
            } else {
                let alert = UIAlertController(title: "Box", message: "iCloud Drive 不可用", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
        uploadalertController.addAction(iCloudDriveAction)
        if let popoverPresentationController = uploadalertController.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .down
            popoverPresentationController.sourceView = uploadButton
            popoverPresentationController.sourceRect = uploadButton.bounds
        }
        present(uploadalertController,animated: true, completion:nil)
    }
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilePreview" {
            let filePreviewViewController = segue.destination as! FilePreviewViewController
            let file = sender as! File
            filePreviewViewController.file = file
            filePreviewViewController.currentFileURL = BoxManager.sharedInstance.getFileURL(file: file)
        }
        if segue.identifier == "showUploadSettings" {
            let navigationController = segue.destination as! UINavigationController
            let uploadSettingsViewController = navigationController.viewControllers.first! as! UploadSettingsViewController
            uploadSettingsViewController.file = sender as! File
        }
    }
    
    // MARK: - Download
    
    @objc func download(code: String) {
        var isPassword: Bool!
        var isMulti: Bool!
        BoxAPI.sharedInstance.getFileInfo(code: code) { code, state, parameter in
            switch state {
            case "Password":
                isPassword = parameter as! Bool
            case "Multi":
                isMulti = parameter as! Bool
            case "Fail":
                let message = parameter as! String
                let alert = UIAlertController(title: "Box", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            case "Success":
                if isPassword == true {
                    let alertController = UIAlertController(title: "需要密码", message: nil, preferredStyle: .alert)
                    alertController.addTextField {
                        (textField: UITextField!) -> Void in
                        textField.placeholder = "请输入私密分享码"
                        textField.adjustsFontSizeToFitWidth = false
                        textField.minimumFontSize = 14
                        textField.returnKeyType = UIReturnKeyType.done
                        textField.autocorrectionType = .no
                        textField.autocapitalizationType = .none
                        textField.clearButtonMode = .whileEditing
                        textField.delegate = self
                        textField.tag = -1
                        textField.addTarget(self, action: #selector(self.textFieldChanged(textField:)), for: .editingChanged)
                    }
                    let okAction = UIAlertAction(title: "确定", style: .default) { action in
                        let password = alertController.textFields!.first!.text!
                        BoxAPI.sharedInstance.checkPassword(code: code, password: password, isMulti: isMulti) { code, state, parameter in
                            switch state {
                            case "Fail":
                                let message = parameter as! String
                                let alert = UIAlertController(title: "Box", message: message, preferredStyle: .alert)
                                let action = UIAlertAction(title: "好", style: .default)
                                alert.addAction(action)
                                self.present(alert, animated: true)
                            case "Success":
                                if isMulti == true {
                                    self.downloadMulti(code: code, password: password)
                                } else {
                                    self.downloadSinggle(code: code, password: password)
                                }
                                break
                            default:
                                break
                            }
                        }
                    }
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    okAction.isEnabled = false
                    self.present(alertController, animated: true)
                } else {
                    if isMulti == true {
                        self.downloadMulti(code: code, password: "-")
                    } else {
                        self.downloadSinggle(code: code, password: "-")
                    }
                }
            default:
                break
            }
        }
    }
    
    func downloadSinggle(code: String, password: String) {
        BoxAPI.sharedInstance.getSinggleFileSuggestName(code: code, password: password) { code, state, parameter in
            switch state {
            case "Fail":
                let message = parameter as! String
                let alert = UIAlertController(title: "Box", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            case "Success":
                let file = BoxManager.sharedInstance.newFile()
                file.code = code
                file.password = password
                file.name = parameter as! String
                file.state = "正在下载"
                let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
                BoxManager.sharedInstance.saveFiles()
                self.files = BoxManager.sharedInstance.allFiles
                let indexPath = IndexPath(row: self.files.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .bottom)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                BoxAPI.sharedInstance.download(code: code, password: password, multiSelect: [0], destURL: fileURL, callback: self.downloadCallBack)
            default:
                break
            }
        }
    }
    
    func downloadMulti(code: String, password: String) {
        var items: [[String: String]] = []
        BoxAPI.sharedInstance.getMultiFiles(code: code, password: password) { code, state, parameter in
            switch state {
            case "Fail":
                let message = parameter as! String
                let alert = UIAlertController(title: "Box", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            case "Item":
                let item = parameter as! [String: String]
                items.append(["text": item["name"]!, "icon": FileRecognizer.getFileIconName(fileName: item["name"]!), "select": "true"])
            case "Success":
                self.downloadMultiSelectView.setItems(items: items)
                self.downloadBarButton.isEnabled = false
                self.downloadMultiSelectView.isHidden = false
                self.downloadMultiSelectView.callBack = { indexes in
                    self.downloadBarButton.isEnabled = true
                    if indexes.count == 0 {
                        return
                    }
                    var name: String!
                    if indexes.count == 1 {
                        name = items[indexes.first!]["text"]!
                    } else {
                        name = "\(code).zip"
                    }
                    let file = BoxManager.sharedInstance.newFile()
                    file.code = code
                    file.password = password
                    file.name = name
                    file.state = "正在下载"
                    let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
                    BoxManager.sharedInstance.saveFiles()
                    self.files = BoxManager.sharedInstance.allFiles
                    let indexPath = IndexPath(row: self.files.count - 1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .bottom)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    BoxAPI.sharedInstance.download(code: code, password: password, multiSelect: indexes, destURL: fileURL, callback: self.downloadCallBack)
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Download CallBack
    
    func downloadCallBack(fileURL: URL, state: String, parameter: Any?) {
        if let file = BoxManager.sharedInstance.getFileByFileURL(fileURL) {
            switch state {
            case "Progress":
                file.progress = NSNumber(value: parameter as! Double)
            case "DueDate":
                file.dueDate = parameter as! Date
            case "Fail":
                file.state = "下载失败"
            case "Success":
                file.progress = NSNumber(value: 1)
                file.state = "已下载"
            default:
                break
            }
            BoxManager.sharedInstance.saveFiles()
            tableView.reloadData()
        }
    }
    
    // MARK: - Upload From AppDelegate
    
    @objc func uploadFromAppDelegate(url: URL) {
        if tableView != nil {
            let file = BoxManager.sharedInstance.newFile()
            file.name = "\(url.path.components(separatedBy: "/").last!)"
            file.state = "正在上传"
            let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
            try! FileManager.default.moveItem(at: url, to: fileURL)
            BoxManager.sharedInstance.saveFiles()
            self.files = BoxManager.sharedInstance.allFiles
            let indexPath = IndexPath(row: self.files.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .bottom)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            BoxAPI.sharedInstance.upload(fileURL: fileURL, callback: uploadCallBack)
        } else {
            perform(#selector(uploadFromAppDelegate(url:)), with: url, afterDelay: 1)
        }
    }
    
    // MARK: - Upload CallBack
    
    func uploadCallBack(fileURL: URL, state: String, parameter: Any?) {
        if let file = BoxManager.sharedInstance.getFileByFileURL(fileURL) {
            switch state {
            case "Progress":
                file.progress = NSNumber(value: parameter as! Double)
            case "Code":
                file.code = parameter as! String
            case "Secid":
                file.secid = parameter as! String
            case "Fail":
                file.state = "上传失败"
            case "Success":
                file.progress = NSNumber(value: 1)
                file.state = "已上传"
                performSegue(withIdentifier: "showUploadSettings", sender: file)
            default:
                break
            }
            BoxManager.sharedInstance.saveFiles()
            tableView.reloadData()
        }
    }
    
}

extension BoxViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noFileImageView.isHidden = files.count > 0
        return files.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BoxViewCell
        cell.icon.image = FileRecognizer.getFileIcon(fileName: files[indexPath.row].name)
        cell.name.text = files[indexPath.row].name
        cell.name.textColor = UIColor.black
        let state = files[indexPath.row].state
        cell.state.text = state + " (" + Date.dateToShortString(date: files[indexPath.row].operationDate) + ")"
        switch state {
        case "下载失败", "上传失败":
            cell.state.textColor = UIColor.red
            cell.indicator.isHidden = false
            cell.progress.isHidden = true
        case "云端到期":
            cell.state.textColor = UIColor.red
            cell.indicator.isHidden = false
            cell.progress.isHidden = true
        case "正在下载", "正在上传":
            cell.state.textColor = UIColor.orange
            cell.indicator.isHidden = true
            cell.progress.current = CGFloat(truncating: files[indexPath.row].progress)
            cell.progress.isHidden = false
        case "已下载", "已上传":
            cell.state.textColor = BoxColor.green
            cell.indicator.isHidden = false
            cell.progress.isHidden = true
        default:
            cell.state.text = "error"
            cell.state.textColor = UIColor.purple
            cell.indicator.isHidden = false
            cell.progress.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch files[indexPath.row].state {
        case "下载失败", "上传失败", "正在下载", "正在上传":
            break
        default:
            performSegue(withIdentifier: "showFilePreview", sender: files[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            BoxManager.sharedInstance.removeFile(file: files[indexPath.row])
            files = BoxManager.sharedInstance.allFiles
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension BoxViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        if picker.navigationItem.prompt == "Upload from PhotoLibrary" || picker.navigationItem.prompt == "Upload from Camera" {
            let file = BoxManager.sharedInstance.newFile()
            file.name = BoxManager.sharedInstance.createRandomFileName(prefix: "Pic", suffix: "png")
            file.state = "正在上传"
            let data = UIImagePNGRepresentation(image)!
            let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
            FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
            BoxManager.sharedInstance.saveFiles()
            self.files = BoxManager.sharedInstance.allFiles
            let indexPath = IndexPath(row: self.files.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .bottom)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            BoxAPI.sharedInstance.upload(fileURL: fileURL, callback: uploadCallBack)
        }
    }
    
}

extension BoxViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let file = BoxManager.sharedInstance.newFile()
        file.name = "\(url.path.components(separatedBy: "/").last!)"
        file.state = "正在上传"
        let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
        try! FileManager.default.moveItem(at: url, to: fileURL)
        BoxManager.sharedInstance.saveFiles()
        self.files = BoxManager.sharedInstance.allFiles
        let indexPath = IndexPath(row: self.files.count - 1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .bottom)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        BoxAPI.sharedInstance.upload(fileURL: fileURL, callback: uploadCallBack)
    }
    
}

extension BoxViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged(textField: UITextField) {
        if textField.tag == -1 {
            let alertController = presentedViewController as! UIAlertController
            let okAction = alertController.actions.last! as UIAlertAction
            okAction.isEnabled = !textField.text!.isEmpty
        }
    }
    
}
