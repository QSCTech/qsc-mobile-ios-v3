//
//  CircleProgressView.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit

import UIKit

class CircleProgressView: UIView {
    
    var doneColor = UIColor(red: 74 / 256.0, green: 144 / 256.0, blue: 226 / 256.0, alpha: 1.0)
    var undoneColor = UIColor(red: 244 / 256.0, green: 244 / 256.0, blue: 244 / 256.0, alpha: 0.9)
    var lineWidth: CGFloat = 3.0
    
    
    var current: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var max: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if current >= max {
            current = max - 0.00001
        }
        
        let radius = rect.width / 2.0 - lineWidth
        let centerX = rect.midX
        let centerY = rect.midY
        let startAngle = -90 * CGFloat.pi / 180
        let endAngle = (current / max * 360 - 90) * CGFloat.pi / 180
        
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(lineWidth)
        context!.setStrokeColor(doneColor.cgColor)
        context!.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context!.strokePath()
        context!.setStrokeColor(undoneColor.cgColor)
        context!.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        context!.strokePath()
    }
    
}
