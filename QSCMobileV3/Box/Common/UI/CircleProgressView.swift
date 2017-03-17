//
//  CircleProgressView.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit

class CircleProgressView: UIView {
    
    var doneColor = UIColor(red: 74 / 255.0, green: 144 / 255.0, blue: 226 / 255.0, alpha: 1.0)
    var undoneColor = UIColor(red: 244 / 255.0, green: 244 / 255.0, blue: 244 / 255.0, alpha: 0.9)
    var lineWidth = CGFloat(3)
    
    var current = CGFloat(0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var max = CGFloat(1) {
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
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startAngle = -90 * CGFloat.pi / 180
        let endAngle = (current / max * 360 - 90) * CGFloat.pi / 180
        
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(lineWidth)
        context!.setStrokeColor(doneColor.cgColor)
        context!.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context!.strokePath()
        context!.setStrokeColor(undoneColor.cgColor)
        context!.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        context!.strokePath()
    }
    
}
