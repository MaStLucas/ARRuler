//
//  SplashScreenViewController.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/25.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Thread.sleep(forTimeInterval: 1.0)
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARRulerScene")
        self.present(vc, animated: true, completion: nil)
    }

}
