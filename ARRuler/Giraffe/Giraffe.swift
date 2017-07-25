//
//  Giraffe.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/25.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class Giraffe: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        draw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        draw()
    }
    
    private func draw() {
        let layer1 = Triangle.init(v1: CGPoint.init(x: 30, y: 30), v2: CGPoint.init(x: 0, y: 30), v3: CGPoint.init(x: 30, y: 0))
        layer1.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        layer1.position = CGPoint.init(x: 15, y: 15)
        layer1.setNeedsDisplay()
        self.layer.addSublayer(layer1)
        
        let layer2 = Triangle.init(v1: CGPoint.init(x: 0, y: 0), v2: CGPoint.init(x: 0, y: 120), v3: CGPoint.init(x: 30, y: 120))
        layer2.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 90)
        layer2.position = CGPoint.init(x: 45, y: 45)
        layer2.setNeedsDisplay()
        self.layer.addSublayer(layer2)
        
        let layer3 = Triangle.init(v1: CGPoint.init(x: 0, y: 0), v2: CGPoint.init(x: 0, y: 30), v3: CGPoint.init(x: 30, y: 0))
        layer3.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        layer3.position = CGPoint.init(x: 45, y: 105)
        layer3.setNeedsDisplay()
        self.layer.addSublayer(layer3)
        
        let layer4 = Triangle.init(v1: CGPoint.init(x: 30, y: 0), v2: CGPoint.init(x: 30, y: 40), v3: CGPoint.init(x: 0, y: 20))
        layer4.bounds = CGRect.init(x: 0, y: 0, width: 30, height: 40)
        layer4.position = CGPoint.init(x: 60, y: 105)
        layer4.setNeedsDisplay()
        self.layer.addSublayer(layer4)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
