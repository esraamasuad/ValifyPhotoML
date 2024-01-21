//
//  PreviewPhotoView.swift
//  ValifyPhotoML
//
//  Created by Esraa on 20/01/2024.
//

import UIKit

class PreviewPhotoView: UIViewController {
    
    /// Data
    var didConfirmPhoto: ((UIImage?) -> Void)?
    var image: UIImage?
    
    /// Outlet
    @IBOutlet weak var pickedImage: UIImageView!
    
    /// Designated initializer
    public class func initWith(_ image: UIImage?) -> PreviewPhotoView {
        let vc = PreviewPhotoView(nibName: "PreviewPhotoView", bundle: Bundle.local)
        vc.image = image
        return vc
    }
    
//    public required init(_ image: UIImage?) {
//        self.image = image
//        super.init(nibName: "PreviewPhotoView", bundle: Bundle.local)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickedImage.image = image
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.leftBarButtonItem = UIBarButtonItem()
    }
}

// MARK: - Actions -

extension PreviewPhotoView {
    @IBAction func retakePhoto(_ button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func usePhoto(_ button: UIButton) {
        didConfirmPhoto?(image)
    }
}
