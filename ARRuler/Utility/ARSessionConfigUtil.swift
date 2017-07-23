//
//  ARSessionConfigUtil.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/22.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import ARKit

class ARSessionConfigUtil {
    
    static func planeDetectionConfig() -> ARWorldTrackingSessionConfiguration {
        let config = ARWorldTrackingSessionConfiguration()
        config.isLightEstimationEnabled = true
        config.planeDetection = .horizontal
        return config
    }
    
}
