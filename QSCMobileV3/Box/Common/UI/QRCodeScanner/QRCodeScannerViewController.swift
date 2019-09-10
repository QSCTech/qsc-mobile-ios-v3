//
//  QRCodeScannerViewController.swift
//  QSCBoxV1
//
//  Created by Zzh on 2016/12/21.
//  Copyright © 2016年 QSC. All rights reserved.
//

import UIKit

class QRCodeScannerViewController: UIViewController {
    
    var callback: ((String) -> ())!

    var scanView: QRCodeScannerView!
    var backButton: UIButton!
    var photoLibraryButton: UIButton!
    var torchButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scanView = QRCodeScannerView()
        scanView.callback = qrcodeScannerViewCallBack
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(scanView)
        
        backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "ScannerBack"), for: .normal)
        backButton.backgroundColor = UIColor.clear
        backButton.addTarget(self, action: #selector(backButtonTapped(button:)), for: .touchDown)
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addConstraint(NSLayoutConstraint(item: backButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40))
        backButton.addConstraint(NSLayoutConstraint(item: backButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40))
        view.addConstraint(NSLayoutConstraint(item: backButton as Any, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 20))
        view.addConstraint(NSLayoutConstraint(item: backButton as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 25))
        
        photoLibraryButton = UIButton(type: .custom)
        photoLibraryButton.setImage(UIImage(named: "PhotoLibrary"), for: .normal)
        photoLibraryButton.backgroundColor = UIColor.clear
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonTapped(button:)), for: .touchDown)
        view.addSubview(photoLibraryButton)
        photoLibraryButton.translatesAutoresizingMaskIntoConstraints = false
        photoLibraryButton.addConstraint(NSLayoutConstraint(item: photoLibraryButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40))
        photoLibraryButton.addConstraint(NSLayoutConstraint(item: photoLibraryButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40))
        view.addConstraint(NSLayoutConstraint(item: photoLibraryButton as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -70))
        view.addConstraint(NSLayoutConstraint(item: photoLibraryButton as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 25))
        
        torchButton = UIButton(type: .custom)
        torchButton.setImage(UIImage(named: "TorchOn"), for: .normal)
        torchButton.tag = 1
        torchButton.backgroundColor = UIColor.clear
        torchButton.addTarget(self, action: #selector(torchButtonTapped(button:)), for: .touchDown)
        view.addSubview(torchButton)
        torchButton.translatesAutoresizingMaskIntoConstraints = false
        torchButton.addConstraint(NSLayoutConstraint(item: torchButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40))
        torchButton.addConstraint(NSLayoutConstraint(item: torchButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40))
        view.addConstraint(NSLayoutConstraint(item: torchButton as Any, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: torchButton as Any, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 25))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scanView.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanView.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func backButtonTapped(button: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func torchButtonTapped(button: UIButton) {
        if torchButton.tag == 1 {
            scanView.torchOn()
            torchButton.setImage(UIImage(named: "TorchOff"), for: .normal)
            torchButton.tag = 0
        } else {
            scanView.torchOff()
            torchButton.setImage(UIImage(named: "TorchOn"), for: .normal)
            torchButton.tag = 1
        }
    }
    
    @objc func photoLibraryButtonTapped(button: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController,animated: true,completion: nil)
        scanView.stop()
    }
    
    func qrcodeScannerViewCallBack(qrcode: String) {
        dismiss(animated: true)
        if callback != nil {
            callback(qrcode)
        }
    }
    
}

extension QRCodeScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        scanView.start()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let ciImage = CIImage(image: image)!
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let features = detector.features(in: ciImage)
        if features.count > 0 {
            let feature = features[0] as! CIQRCodeFeature
            let qrcode = feature.messageString!
            dismiss(animated: true)
            if callback != nil {
                callback(qrcode)
            }
        } else {
            let alert = UIAlertController(title: "未读取到二维码", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
            scanView.start()
        }
    }
    
}
