//
//  UIImage+Border.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/27.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func imageWithBorder(borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        
        let imageSize = CGSize.init(width: self.size.width+CGFloat(2)*borderWidth, height: self.size.height+CGFloat(2)*borderWidth)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            
            context.setFillColor(borderColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            
            self.draw(in: CGRect(x: borderWidth, y: borderWidth, width: self.size.width, height: self.size.height))
            
            let text: NSString = "Measured by ARuler"
            let textSize = text.size(withAttributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 9)])
            text.draw(in: CGRect.init(origin: CGPoint.init(x: (imageSize.width-textSize.width)/CGFloat(2), y: imageSize.height-textSize.height-CGFloat(20)), size: size), withAttributes: [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 9),
                NSAttributedStringKey.foregroundColor : UIColor.init(white: 0xffffff, alpha: 0.5)
                ])
            
            let watermarkImage = #imageLiteral(resourceName: "watermark")
            watermarkImage.draw(in: CGRect.init(x: (imageSize.width-watermarkImage.size.width)/CGFloat(2), y: imageSize.height-watermarkImage.size.height-textSize.height-CGFloat(30), width: watermarkImage.size.width, height: watermarkImage.size.height))
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
