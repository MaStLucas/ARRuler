//
//  ShareViewController.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/26.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    var image: UIImage!
    
    @IBOutlet weak var screenShot: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        screenShot.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let activityVC = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
