//
//  ScreenShotUtil.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/30.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import UIKit

class ScreenShotUtil {
    
    class func screenshot() -> UIImage? {
        var imageSize = CGSize.zero
        
        let orientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsPortrait(orientation) {
            imageSize = UIScreen.main.bounds.size
        } else {
            imageSize = CGSize(width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            for window in UIApplication.shared.windows {
                context.saveGState()
                context.translateBy(x: window.center.x, y: window.center.y)
                context.concatenate(window.transform)
                context.translateBy(x: -window.bounds.size.width * window.layer.anchorPoint.x, y: -window.bounds.size.height * window.layer.anchorPoint.y)
                if orientation == .landscapeLeft {
                    context.rotate(by: .pi/2)
                    context.translateBy(x: 0, y: -imageSize.width)
                } else if orientation == .landscapeRight {
                    context.rotate(by: .pi/2)
                    context.translateBy(x: -imageSize.height, y: 0)
                } else if orientation == .portraitUpsideDown {
                    context.rotate(by: .pi)
                    context.translateBy(x: -imageSize.width, y: -imageSize.width)
                }
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                context.restoreGState()
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
        
    }
}
