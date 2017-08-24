//
//  HexagonPiece.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/24.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class HexagonPiece: CALayer {
    
    private let verticalMargin: CGFloat = 2
    private let horizontalMargin: CGFloat = 2*2*tan(CGFloat.pi/3.0)

    override func draw(in ctx: CGContext) {
        ctx.move(to: CGPoint(x: 0+horizontalMargin, y: self.bounds.height-verticalMargin))
        ctx.addLine(to: CGPoint(x: self.bounds.width/CGFloat(2), y: 0+verticalMargin))
        ctx.addLine(to: CGPoint.init(x: self.bounds.width-horizontalMargin, y: self.bounds.height-verticalMargin))
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.setStrokeColor(UIColor(named: "GiraffeYellow")!.cgColor)
        ctx.setLineWidth(4)
        ctx.strokePath()
    }
}
