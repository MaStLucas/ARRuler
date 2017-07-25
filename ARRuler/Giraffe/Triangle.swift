//
//  Triangle.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/26.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class Triangle: CALayer {

    private var vertex1 = CGPoint.zero
    private var vertex2 = CGPoint.zero
    private var vertex3 = CGPoint.zero
    
    init(v1: CGPoint, v2: CGPoint, v3: CGPoint) {
        super.init()
        vertex1 = v1
        vertex2 = v2
        vertex3 = v3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        ctx.setFillColor(UIColor.yellow.cgColor)
        ctx.addLines(between: [vertex1, vertex2, vertex3])
        ctx.closePath()
        ctx.fillPath()
    }
    
}
