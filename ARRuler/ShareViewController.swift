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
        if let borderedImage = image.imageWithBorder(borderWidth: 0, borderColor: UIColor.white) {
            screenShot.image = borderedImage
        }
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
        
        let shareString = NSMutableAttributedString()
        shareString.append(NSAttributedString.init(string: NSLocalizedString("ARuler - the most interesting AR measure tool", comment: "")))
        shareString.append(NSAttributedString.init(string: "\n"))
        shareString.append(NSAttributedString.init(string: NSLocalizedString("Download here", comment: ""), attributes: [NSAttributedStringKey.link : URL.init(string: "https://itunes.apple.com/us/app/aruler-ar-measuring-tool/id1281344946")!]))
        
        let activityVC = UIActivityViewController.init(activityItems: [shareString, screenShot.image!], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
//        switch PHPhotoLibrary.authorizationStatus() {
//        case .authorized:
//            saveToAlbum()
//        case .restricted, .denied:
//            let title = "Photos access denied"
//            let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
//            self.showAlert(title: title, message: message)
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
//                if authorizationStatus == .authorized {
//                    self.saveToAlbum()
//                }
//            })
//        }
        saveToAlbum()
    }
    
    private func saveToAlbum() {
        PhotoAlbumUtil.saveImageInAlbum(image: screenShot.image!, albumName: "ARuler") { result in
            switch result {
            case .success:
                self.showAlert(title: NSLocalizedString("Save success", comment: ""), message: "")
            case .error:
                self.showAlert(title: NSLocalizedString("Save error", comment: ""), message: "")
            case .denied:
                let title = NSLocalizedString("Photos access denied", comment: "")
                let message = NSLocalizedString("Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.", comment: "")
                self.showAlert(title: title, message: message)
            }
        }
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
