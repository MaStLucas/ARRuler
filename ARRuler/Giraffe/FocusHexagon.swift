//
//  FocusHexagon.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/6.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class FocusHexagon: UIView {

    var trianglePieces: [Triangle] = []
//    var hexagonPieces: [HexagonPiece] = []
    var aimPoint = CALayer()
    
    var hasFocused = true
    
    let unfocusRadius: CGFloat = 4*25
    let focusRadius: CGFloat = 1*25
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let localCenter = CGPoint.init(x: rect.width/2, y: rect.height/2)
        
        aimPoint.bounds = CGRect.init(x: 0, y: 0, width: 4, height: 4)
        aimPoint.position = localCenter
        aimPoint.cornerRadius = 2
        aimPoint.backgroundColor = UIColor(named: "GiraffeYellow")!.cgColor
        self.layer.addSublayer(aimPoint)
        
        for i in 1...6 {
            let layer = Triangle.init(v1: CGPoint.init(x: 0, y: 6), v2: CGPoint.init(x: 6, y: 6), v3: CGPoint.init(x: 3, y: 0))
            layer.bounds = CGRect.init(x: 0, y: 0, width: 6, height: 6)
            layer.position = localCenter
            layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, unfocusRadius, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i-1), 0, 0, 1))
            layer.setNeedsDisplay()
            self.layer.addSublayer(layer)
            self.trianglePieces.append(layer)
            
//            let layer = Triangle.init(v1: CGPoint.init(x: 0, y: 6), v2: CGPoint.init(x: 6, y: 6), v3: CGPoint.init(x: 3, y: 0))
//            layer.bounds = CGRect.init(x: 0, y: 0, width: 6, height: 6)
//            layer.position = localCenter
//            layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, 30, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(6)-CGFloat.pi/CGFloat(3)*CGFloat(i-1), 0, 0, 1))
//            layer.setNeedsDisplay()
//            self.layer.addSublayer(layer)
//            self.trianglePieces.append(layer)
//
//            let layer2 = HexagonPiece.init()
//            layer2.bounds = CGRect.init(x: 0, y: 0, width: tan(CGFloat.pi/3.0)*2.0*25.0/2.0, height: 25.0/2.0)
//            layer2.position = localCenter
//            layer2.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, -2.0*25.0, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i-1), 0, 0, 1))
//            layer2.setNeedsDisplay()
//            self.layer.addSublayer(layer2)
//            self.hexagonPieces.append(layer2)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

//    func blink() {
//
//        for (i, piece) in hexagonPieces.enumerated() {
//            let alphaAnimation = CAKeyframeAnimation.init(keyPath: "opacity")
//            alphaAnimation.duration = 0.8
//            switch(i)
//            {
//            case 0:
//                alphaAnimation.values = [1.0/6.0, 2.0/6.0, 3.0/6.0, 4.0/6.0, 5.0/6.0, 1]
//            case 1:
//                alphaAnimation.values = [2.0/6.0, 3.0/6, 4.0/6.0, 5.0/6.0, 1, 1.0/6.0]
//            case 2:
//                alphaAnimation.values = [3.0/6.0, 4.0/6.0, 5.0/6.0, 1, 1.0/6.0, 2.0/6.0]
//            case 3:
//                alphaAnimation.values = [4.0/6.0, 5.0/6.0, 1, 1.0/6.0, 2.0/6.0, 3.0/6.0]
//            case 4:
//                alphaAnimation.values = [5.0/6.0, 1, 1.0/6.0, 2.0/6.0, 3.0/6.0, 4.0/6.0]
//            case 5:
//                alphaAnimation.values = [1, 1.0/6.0, 2.0/6.0, 3.0/6.0, 4.0/6.0, 5.0/6.0]
//            default:
//                break
//            }
//            alphaAnimation.repeatCount = Float.greatestFiniteMagnitude
//            alphaAnimation.isRemovedOnCompletion = false
//            alphaAnimation.fillMode = kCAFillModeForwards
//            alphaAnimation.calculationMode = kCAAnimationDiscrete
//            piece.add(alphaAnimation, forKey: "blink")
//        }
//    }
    
    func rotate() {
        
        let rotateAnimation = CAKeyframeAnimation.init(keyPath: "transform")
        rotateAnimation.duration = 3
        
        rotateAnimation.values = [
            CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(0), 0, 0, 1),
            CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(1), 0, 0, 1),
            CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(2), 0, 0, 1),
            CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(3), 0, 0, 1),
            CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(4), 0, 0, 1),
            CATransform3DMakeRotation(CGFloat.pi/CGFloat(3)*CGFloat(5), 0, 0, 1)
        ]
        
        rotateAnimation.repeatCount = Float.greatestFiniteMagnitude
        rotateAnimation.isRemovedOnCompletion = false
        self.layer.add(rotateAnimation, forKey: "rotate")
    }
    
    func focus() {
        
        if hasFocused {
            return
        }
        hasFocused = true
        
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.8)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn))
        CATransaction.setCompletionBlock({
            self.layer.removeAnimation(forKey: "rotate")
        })
        self.layer.transform = CATransform3DIdentity
        for (i, piece) in trianglePieces.enumerated() {
            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, focusRadius, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i), 0, 0, 1))
            piece.opacity = 0.2
        }
//        for (i, piece) in trianglePieces.enumerated() {
//            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, 12, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(6)-CGFloat.pi/CGFloat(3)*CGFloat(i), 0, 0, 1))
//            piece.opacity = 1.0
//        }
//        for (i, piece) in hexagonPieces.enumerated() {
//            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, -focusRadius, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i-1), 0, 0, 1))
//            piece.opacity = 0.1
//        }
        aimPoint.opacity = 1.0
        CATransaction.commit()
    }
    
    func unfocus() {
        
        if !hasFocused {
            return
        }
        hasFocused = false
        
        rotate()
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.8)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn))
        for (i, piece) in trianglePieces.enumerated() {
            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, unfocusRadius, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i), 0, 0, 1))
            piece.opacity = 1.0
        }
//        for (i, piece) in trianglePieces.enumerated() {
//            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, 30, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(6)-CGFloat.pi/CGFloat(3)*CGFloat(i), 0, 0, 1))
//            piece.opacity = 0.1
//        }
//        for (i, piece) in hexagonPieces.enumerated() {
//            piece.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, -unfocusRadius, 0), CATransform3DMakeRotation(-CGFloat.pi/CGFloat(3)*CGFloat(i-1), 0, 0, 1))
//            piece.opacity = 1.0
//        }
        aimPoint.opacity = 0
        CATransaction.commit()
    }
}
