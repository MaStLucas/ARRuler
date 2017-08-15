//
//  FocusHexagon.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/6.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class FocusHexagon: UIView {

    var pieces: [Triangle] = []
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: CGPoint(x: rect.width/2.0, y: 0))
            ctx.addLine(to: CGPoint(x: rect.width/2.0+tan(CGFloat.pi/3.0)*rect.width/4.0, y: rect.width/4.0))
            ctx.addLine(to: CGPoint(x: rect.width/2.0+tan(CGFloat.pi/3.0)*rect.width/4.0, y: rect.width*3.0/4.0))
            ctx.addLine(to: CGPoint(x: rect.width/2.0, y: rect.width))
            ctx.addLine(to: CGPoint(x: rect.width/2.0-tan(CGFloat.pi/3.0)*rect.width/4.0, y: rect.width*3.0/4.0))
            ctx.addLine(to: CGPoint(x: rect.width/2.0-tan(CGFloat.pi/3.0)*rect.width/4.0, y: rect.width/4.0))
            ctx.closePath()
            ctx.strokePath()
        }
        
        for i in 1...6 {
            let localCenter = CGPoint.init(x: rect.width/2, y: rect.height/2)
            let layer = Triangle.init(v1: CGPoint.init(x: 0, y: 6), v2: CGPoint.init(x: 6, y: 6), v3: CGPoint.init(x: 3, y: 0))
            layer.bounds = CGRect.init(x: 0, y: 0, width: 6, height: 6)
            layer.position = localCenter
            layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, 30, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i-1), 0, 0, 1))
            layer.allowsEdgeAntialiasing = true
            layer.setNeedsDisplay()
            self.layer.addSublayer(layer)
            self.pieces.append(layer)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

    func animate() {
        
        for (i, piece) in pieces.enumerated() {
            let alphaAnimation = CAKeyframeAnimation.init(keyPath: "opacity")
            alphaAnimation.duration = 0.8
            switch(i)
            {
            case 0:
                alphaAnimation.values = [1.0/6.0, 2.0/6.0, 3.0/6.0, 4.0/6.0, 5.0/6.0, 1]
            case 1:
                alphaAnimation.values = [2.0/6.0, 3.0/6, 4.0/6.0, 5.0/6.0, 1, 1.0/6.0]
            case 2:
                alphaAnimation.values = [3.0/6.0, 4.0/6.0, 5.0/6.0, 1, 1.0/6.0, 2.0/6.0]
            case 3:
                alphaAnimation.values = [4.0/6.0, 5.0/6.0, 1, 1.0/6.0, 2.0/6.0, 3.0/6.0]
            case 4:
                alphaAnimation.values = [5.0/6.0, 1, 1.0/6.0, 2.0/6.0, 3.0/6.0, 4.0/6.0]
            case 5:
                alphaAnimation.values = [1, 1.0/6.0, 2.0/6.0, 3.0/6.0, 4.0/6.0, 5.0/6.0]
            default:
                break
            }
            alphaAnimation.repeatCount = Float.greatestFiniteMagnitude
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = kCAFillModeForwards
            alphaAnimation.calculationMode = kCAAnimationDiscrete
            piece.add(alphaAnimation, forKey: nil)
        }
    }
    
    func focus() {
        for (i, piece) in pieces.enumerated() {
            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, 12, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i), 0, 0, 1))
        }
    }
    
    func unfocus() {
        for (i, piece) in pieces.enumerated() {
            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, 30, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i), 0, 0, 1))
        }
    }
}
