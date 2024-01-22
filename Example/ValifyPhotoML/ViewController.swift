//
//  ViewController.swift
//  ValifyPhotoML
//
//  Created by esraa on 01/18/2024.
//  Copyright (c) 2024 esraa. All rights reserved.
//

import UIKit
import ValifyPhotoML

class ViewController: UIViewController {
    
    /// Outlet
    @IBOutlet weak var userImage:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
     }
}

// MARK: - Actions [Take a photo] -

extension ViewController {
    
    @IBAction func takePhotoAction(_ button: UIButton) {
        
        /// Use a framework to pick a photo
        let picker = TakePhoto()
        picker.didFinishPicking { [unowned picker] photo, _ in
            self.userImage.image = photo
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
}
