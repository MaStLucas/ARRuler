//
//  TipText.swift
//  ARRuler
//
//  Created by StephenMa on 2017/9/8.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class TipText: UITextView {

    private let cornerLength:CGFloat = 4
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(UIColor(named: "GiraffeYellow")!.cgColor)
            ctx.addLines(between: [CGPoint.init(x: 0, y: 0), CGPoint.init(x: cornerLength, y: 0), CGPoint.init(x: 0, y: cornerLength)])
            ctx.addLines(between: [CGPoint.init(x: rect.width, y: 0), CGPoint.init(x: rect.width-cornerLength, y: 0), CGPoint.init(x: rect.width, y: cornerLength)])
            ctx.addLines(between: [CGPoint.init(x: 0, y: rect.height), CGPoint.init(x: cornerLength, y: rect.height), CGPoint.init(x: 0, y: rect.height-cornerLength)])
            ctx.addLines(between: [CGPoint.init(x: rect.width, y: rect.height), CGPoint.init(x: rect.width-cornerLength, y: rect.height), CGPoint.init(x: rect.width, y: rect.height-cornerLength)])
            ctx.closePath()
            ctx.fillPath()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

}
