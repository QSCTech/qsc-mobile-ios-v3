//
//  QRCodeScannerView.swift
//  QSCBoxV1
//
//  Created by Zzh on 2016/12/21.
//  Copyright © 2016年 QSC. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeScannerView: UIView {
    
    var callback: ((String) -> ())!
    
    let screenBounds = UIScreen.main.bounds
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    let scanSpaceOffset: CGFloat = 0.15
    var scanRect: CGRect!
    
    var device: AVCaptureDevice!
    var captureSession: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var output: AVCaptureMetadataOutput!
    
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
    var shadowLayer: CAShapeLayer!
    var scanRectLayer: CAShapeLayer!
    var remindLabel: UILabel!
    
    init() {
        super.init(frame: screenBounds)
        
        backgroundColor = UIColor(white: 0, alpha: 0.2)
        if initCaptureVideoPreviewLayer() {
            setScanRect()
            addShadowLayer()
            addScanRectLayer()
            addRemindLabel()
            layer.masksToBounds = true
        } else {
            remindLabel = UILabel()
            remindLabel.text = "Error"
            remindLabel.textColor = UIColor.white
            remindLabel.font = UIFont.systemFont(ofSize: 15)
            remindLabel.textAlignment = .center
            remindLabel.adjustsFontSizeToFitWidth = false
            addSubview(remindLabel)
            remindLabel.translatesAutoresizingMaskIntoConstraints = false
            remindLabel.addConstraint(NSLayoutConstraint(item: remindLabel as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: +20))
            remindLabel.addConstraint(NSLayoutConstraint(item: remindLabel as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: +100))
            addConstraint(NSLayoutConstraint(item: remindLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            addConstraint(NSLayoutConstraint(item: remindLabel as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func start() {
        if captureSession != nil {
            captureSession.startRunning()
        }
    }
    
    func stop() {
        if captureSession != nil {
            captureSession.stopRunning()
        }
    }
    
    func torchOn() {
        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func torchOff() {
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func initCaptureVideoPreviewLayer() -> Bool {
        var noError: Bool!
        device = AVCaptureDevice.default(for: AVMediaType.video)
        if device != nil {
            captureSession = AVCaptureSession()
            do {
                input = try AVCaptureDeviceInput(device: device)
                if (captureSession!.canAddInput(input)) {
                    captureSession!.addInput(input)
                }
                output = AVCaptureMetadataOutput()
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                if (captureSession!.canAddOutput(output)) {
                    captureSession!.addOutput(output)
                    output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                }
                captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
                captureVideoPreviewLayer.frame = bounds
                layer.addSublayer(captureVideoPreviewLayer)
                noError = true
            } catch let error as NSError {
                print(error)
                noError = false
            }
        } else {
            noError = false
        }
        return noError
    }
    
    func setScanRect() {
        let size = screenWidth * (1 - 2 * scanSpaceOffset)
        let minY = (screenHeight - size) * 0.5 / screenHeight
        let maxY = (screenHeight + size) * 0.5 / screenHeight
        output.rectOfInterest = CGRect(x: minY, y: scanSpaceOffset, width: maxY, height: 1 - scanSpaceOffset * 2)
        let yOffset = output.rectOfInterest.size.width - output.rectOfInterest.origin.x
        let xOffset = 1 - 2 * scanSpaceOffset
        scanRect = CGRect(x: output.rectOfInterest.origin.y * screenWidth, y: output.rectOfInterest.origin.x * screenHeight, width: xOffset * screenWidth, height: yOffset * screenHeight)
    }
    
    func addShadowLayer() {
        shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(rect: bounds).cgPath
        shadowLayer.fillColor = UIColor(white: 0, alpha: 0.3).cgColor
        shadowLayer.mask = generateMaskLayerWithRect(rect: screenBounds, exceptRect: scanRect)
        layer.addSublayer(shadowLayer)
    }
    
    func addScanRectLayer() {
        var rect = scanRect!
        rect.origin.x -= 1
        rect.origin.y -= 1
        rect.size.width += 2
        rect.size.height += 2
        scanRectLayer = CAShapeLayer()
        scanRectLayer.path = UIBezierPath(rect: rect).cgPath
        scanRectLayer.fillColor = UIColor.clear.cgColor
        scanRectLayer.strokeColor = UIColor(red: 0 / 255.0, green: 122 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
        scanRectLayer.lineWidth = 5
        layer.addSublayer(scanRectLayer)
    }
    
    func addRemindLabel() {
        var rect = scanRect!
        rect.origin.y += rect.height + 20
        rect.size.height = 25
        remindLabel = UILabel(frame: rect)
        remindLabel.font = UIFont.systemFont(ofSize: 15 * screenWidth / 375)
        remindLabel.textColor = UIColor.white
        remindLabel.textAlignment = .center
        remindLabel.text = "将二维码放入框内"
        remindLabel.backgroundColor = UIColor.clear
        addSubview(remindLabel)
    }
    
    func generateMaskLayerWithRect(rect: CGRect, exceptRect: CGRect) -> CAShapeLayer? {
        let maskLayer = CAShapeLayer()
        if !rect.contains(exceptRect) {
            return nil
        } else if rect.equalTo(CGRect.zero) {
            maskLayer.path = UIBezierPath(rect: rect).cgPath
            return maskLayer
        }
        let boundsInitX = rect.minX
        let boundsInitY = rect.minY
        let boundsWidth = rect.width
        let boundsHeight = rect.height
        let minX = exceptRect.minX
        let maxX = exceptRect.maxX
        let minY = exceptRect.minY
        let maxY = exceptRect.maxY
        let width = exceptRect.width
        let path = UIBezierPath(rect: CGRect(x: boundsInitX, y: boundsInitY, width: minX, height: boundsHeight))
        path.append(UIBezierPath(rect: CGRect(x: minX, y: boundsInitY, width: width, height: minY)))
        path.append(UIBezierPath(rect: CGRect(x: maxX, y: boundsInitY, width: boundsWidth - maxX, height: boundsHeight)))
        path.append(UIBezierPath(rect: CGRect(x: minX, y: maxY, width: width, height: boundsHeight - maxY)))
        maskLayer.path = path.cgPath
        return maskLayer
    }
    
}

extension QRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            stop()
            removeFromSuperview()
            let metadataObject = metadataObjects.first! as! AVMetadataMachineReadableCodeObject
            if callback != nil {
                callback(metadataObject.stringValue!)
            }
        }
    }
    
}
