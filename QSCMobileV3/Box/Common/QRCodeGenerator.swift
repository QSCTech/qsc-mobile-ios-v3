//
//  QRCodeGenerator.swift
//  QSCBoxV1
//
//  Created by Zzh on 2016/12/21.
//  Copyright © 2016年 QSC. All rights reserved.
//

import UIKit

class QRCodeGenerator {
    
    static func createImage(qrcode: String, size: CGFloat) -> UIImage {
        let qrData = qrcode.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(qrData, forKey: "inputMessage")
        let qrCIImage = qrFilter.outputImage!
        let qrImage = createNonInterpolatedUIImage(from: qrCIImage, size: size)
        return qrImage
    }
    
    static func createNonInterpolatedUIImage(from image: CIImage, size: CGFloat) -> UIImage {
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size / extent.width, size / extent.height)
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale)
        bitmapRef.draw(bitmapImage, in: extent)
        let scaledImage: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: scaledImage)
    }
    
}
