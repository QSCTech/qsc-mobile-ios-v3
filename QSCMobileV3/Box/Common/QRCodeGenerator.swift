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
        let qrData = qrcode.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let qrFilter = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": qrData])!
        let qrCIImage = qrFilter.outputImage!
        let qrImage = createNonInterpolatedUIImage(from: qrCIImage, size: size)
        return qrImage
    }
    
    static func createNonInterpolatedUIImage(from image: CIImage, size: CGFloat) -> UIImage {
        let extent = image.extent.integral
        let scale = min(size / extent.width, size / extent.height)
        let width = extent.width * scale
        let height = extent.height * scale
        let cs = CGColorSpaceCreateDeviceGray()
        let bitmap = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        bitmap.interpolationQuality = CGInterpolationQuality.none
        bitmap.scaleBy(x: scale, y: scale)
        let bitmapImage = CIContext(options: nil).createCGImage(image, from: extent)!
        bitmap.draw(bitmapImage, in: extent)
        let scaledImage = bitmap.makeImage()!
        return UIImage(cgImage: scaledImage)
    }
    
}
