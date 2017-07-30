//
//  Tip.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/31.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class Tip: UILabel {

    let cornerLength: CGFloat = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(UIColor.yellow.cgColor)
            ctx.addLines(between: [CGPoint.init(x: 0, y: 0), CGPoint.init(x: cornerLength, y: 0), CGPoint.init(x: 0, y: cornerLength)])
            ctx.addLines(between: [CGPoint.init(x: rect.width, y: 0), CGPoint.init(x: rect.width-cornerLength, y: 0), CGPoint.init(x: rect.width, y: cornerLength)])
            ctx.addLines(between: [CGPoint.init(x: 0, y: rect.height), CGPoint.init(x: cornerLength, y: rect.height), CGPoint.init(x: 0, y: rect.height-cornerLength)])
            ctx.addLines(between: [CGPoint.init(x: rect.width, y: rect.height), CGPoint.init(x: rect.width-cornerLength, y: rect.height), CGPoint.init(x: rect.width, y: rect.height-cornerLength)])
            ctx.closePath()
            ctx.fillPath()
        }
        
        super.draw(rect)
    }

}
