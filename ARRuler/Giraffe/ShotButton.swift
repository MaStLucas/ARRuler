//
//  ShotButton.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/27.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class ShotButton: UIView {

    let slot: CGFloat = 30
    
    var pieces: [Triangle] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func animate() {
        for (i, piece) in pieces.enumerated() {
            let alphaAnimation = CAKeyframeAnimation.init(keyPath: "opacity")
            alphaAnimation.duration = 1
            alphaAnimation.values = [1/6, 2/6, 3/6, 4/6, 5/6, 1]
            let currentTime = layer.convertTime(CACurrentMediaTime(), to: nil)
            alphaAnimation.beginTime = currentTime+CFTimeInterval(i)
            alphaAnimation.repeatCount = Float.greatestFiniteMagnitude
            alphaAnimation.isRemovedOnCompletion = false
            alphaAnimation.fillMode = kCAFillModeForwards
            alphaAnimation.autoreverses = true
            alphaAnimation.calculationMode = kCAAnimationDiscrete
            piece.add(alphaAnimation, forKey: nil)
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        for i in 1...6 {
            let localCenter = CGPoint.init(x: rect.width/2, y: rect.height/2)
            let layer = Triangle.init(v1: CGPoint.init(x: 0, y: 0), v2: CGPoint.init(x: 0, y: slot), v3: CGPoint.init(x: CGFloat(sqrtf(3))*slot, y: 0))
            layer.bounds = CGRect.init(x: 0, y: 0, width: slot*sqrt(3), height: slot)
            layer.position = localCenter
            layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, -slot, 0), CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(i)-CGFloat.pi/CGFloat(6), 0, 0, 1))
            layer.setNeedsDisplay()
            self.layer.addSublayer(layer)
            self.pieces.append(layer)
        }
    }

}
