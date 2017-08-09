//
//  ARCameraTrackingState.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/23.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import Foundation
import ARKit

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "TRACKING LIMITED: Too much camera movement"
            case .insufficientFeatures:
                return "TRACKING LIMITED: Not enough surface detail"
            case .initializing:
                return "TRACKING LIMITED: Initializing"
            }
        }
    }
}
