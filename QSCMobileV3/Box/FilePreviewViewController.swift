//
//  FilePreviewViewController.swift
//  QSCBoxV1
//
//  Created by Zzh on 2016/11/19.
//  Copyright © 2016年 QSC. All rights reserved.
//

import UIKit
import QSCMobileKit

class FilePreviewViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var file: File!
    var currentFileURL: URL!
    var currentFileName: String!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var unknownView: UIView!
    
    var items: [[String: String]] = []
    
    var documentInteractionController: UIDocumentInteractionController!
    var openWithOtherAppsBarButtonItem: UIBarButtonItem!
    
    var hidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentFileName = currentFileURL.path.components(separatedBy: "/").last!
        
        navigationItem.title = currentFileName
        let backBarButtonItem = UIBarButtonItem(title: "返回", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        if currentFileURL != BoxManager.sharedInstance.getFileURL(file: file) {
            navigationItem.setRightBarButton(nil, animated: false)
        }
        
        let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        openWithOtherAppsBarButtonItem = UIBarButtonItem(title: "用其它应用打开", style: .plain, target: self, action: #selector(openWithOtherAppsBarButtonTapped(_:)))
        setToolbarItems([flexibleSpaceBarButtonItem, openWithOtherAppsBarButtonItem, flexibleSpaceBarButtonItem], animated: false)
        navigationController!.toolbar.tintColor = navigationController!.navigationBar.tintColor
        
        if FileRecognizer.getFileIconName(fileName: currentFileName) == "Picture" {
            let data = try! Data(contentsOf: currentFileURL)
            imageView.image = UIImage(data: data)
            imageView.isHidden = false
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            longPressGestureRecognizer.allowableMovement = 100
            view.addGestureRecognizer(longPressGestureRecognizer)
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler)))
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        } else if currentFileName.lowercased().hasSuffix(".zip") == true {
            let unzipURL = BoxManager.sharedInstance.getUnzipURL(file: file)
            if FileManager.default.fileExists(atPath: unzipURL.path) == false {
                BoxManager.sharedInstance.unzip(file: file)
            }
            for fileName in FileManager.default.enumerator(atPath: unzipURL.path)! {
                var isDirectory: ObjCBool = true
                FileManager.default.fileExists(atPath: unzipURL.appendingPathComponent("\(fileName)").path, isDirectory: &isDirectory)
                if isDirectory.boolValue == false && "\(fileName)".hasSuffix(".DS_Store") == false {
                    items.append(["text": "\(fileName)", "iconName": FileRecognizer.getFileIconName(fileName: "\(fileName)")])
                }
            }
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isHidden = false
        } else {
            webView.delegate = self
            webView.dataDetectorTypes = .all
            webView.scalesPageToFit = true
            webView.backgroundColor = UIColor.clear
            webView.loadRequest(URLRequest(url: currentFileURL))
            webView.isHidden = false
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.delegate = self
            tapGestureRecognizer.cancelsTouchesInView = false
            webView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        documentInteractionController = UIDocumentInteractionController(url: currentFileURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationController!.setToolbarHidden(false, animated: true)
        
        if tableView.isHidden {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.allowsRotation = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationController!.setToolbarHidden(true, animated: true)
        
        if tableView.isHidden {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.allowsRotation = false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if tableView.isHidden {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return hidden
    }
    
    // MARK: - Buttons Tapped
    
    @IBAction func detailsBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showFileDetails", sender: file)
    }
    
    @objc func openWithOtherAppsBarButtonTapped(_ sender: UIBarButtonItem) {
        documentInteractionController.presentOptionsMenu(from: openWithOtherAppsBarButtonItem, animated: true)
    }
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFileDetails" {
            let fileDetailsViewController = segue.destination as! FileDetailsViewController
            fileDetailsViewController.file = (sender as! File)
        }
    }
    
    // MARK: - Gesture Handlers
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func tapHandler(_ sender: UITapGestureRecognizer) {
        hidden = !hidden
        navigationController!.setNavigationBarHidden(hidden, animated: true)
        navigationController!.setToolbarHidden(hidden, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func pinchHandler(_ sender: UIPinchGestureRecognizer) {
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    @objc func longPressHandler(_ sender: UITapGestureRecognizer) {
        documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
    }
    
}

extension FilePreviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView!.image = UIImage(named: items[indexPath.row]["iconName"]!)
        cell.textLabel!.text = items[indexPath.row]["text"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Box", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "filePreview") as! FilePreviewViewController
        vc.file = file
        vc.currentFileURL = BoxManager.sharedInstance.getUnzipURL(file: file).appendingPathComponent(items[indexPath.row]["text"]!)
        show(vc, sender: nil)
    }
    
}

extension FilePreviewViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if FileRecognizer.getFileIconName(fileName: currentFileName) == "Video" && (error as NSError).code == 204 {
            return
        }
        webView.isHidden = true
        unknownView.isHidden = false
    }
    
}
