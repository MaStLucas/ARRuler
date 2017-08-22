//
//  ShareViewController.swift
//  ARRuler
//
//  Created by StephenMa on 2017/7/26.
//  Copyright © 2017年 Stephen Ma. All rights reserved.
//

import UIKit
import Photos

class ShareViewController: UIViewController {

    var image: UIImage!
    
    @IBOutlet weak var screenShot: UIImageView!
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        screenShot.image = image
        background.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let activityVC = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            saveToAlbum()
        case .restricted, .denied:
            let title = "Photos access denied"
            let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
            self.showAlert(title: title, message: message)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    self.saveToAlbum()
                }
            })
        }
    }
    
    private func saveToAlbum() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
