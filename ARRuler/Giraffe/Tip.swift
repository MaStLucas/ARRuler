//
//  Tip.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/31.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class Tip: UILabel {

    private let horizontalInset:CGFloat = 15
    private let verticalInset:CGFloat = 10
    private let cornerLength:CGFloat = 4
    
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
        
        super.drawText(in: rect.insetBy(dx: horizontalInset, dy: verticalInset))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var size = super.intrinsicContentSize
            size.width += 2*horizontalInset
            size.height += 2*verticalInset
            return size
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

}
