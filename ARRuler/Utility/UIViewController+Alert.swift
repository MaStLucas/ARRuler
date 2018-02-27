//
//  UIViewController+Alert.swift
//  ARRuler
//
//  Created by StephenMa on 2017/8/23.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alertController.addAction(action)
            }
        } else {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
