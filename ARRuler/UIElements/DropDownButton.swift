//
//  DropDownButton.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/21.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class DropDownButton: UIButton {

    private let cornerLength:CGFloat = 4
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(UIColor.yellow.cgColor)
            ctx.addLines(between: [CGPoint.init(x: rect.width, y: rect.height), CGPoint.init(x: rect.width-cornerLength, y: rect.height), CGPoint.init(x: rect.width, y: rect.height-cornerLength)])
            ctx.closePath()
            ctx.fillPath()
        }
        
        super.draw(rect)
    }

}
