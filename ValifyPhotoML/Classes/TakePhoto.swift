//
//  TakePhoto.swift
//  ValifyPhotoML
//
//  Created by Esraa on 20/01/2024.
//

import Foundation
import AVFoundation
import UIKit

public class TakePhoto: UINavigationController {
    
    public typealias DidFinishPickingCompletion = (_ items: UIImage?, _ cancelled: Bool) -> Void
    
    public func didFinishPicking(completion: @escaping DidFinishPickingCompletion) {
        _didFinishPicking = completion
    }
    
    private var _didFinishPicking: DidFinishPickingCompletion?
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    deinit {
        print("Picker deinited 👍")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        /// Add CameraView
        let cameraView = CameraPickerView()
        cameraView.didPickPhoto = { [weak self] img in
            self?._didFinishPicking?(img, false)
        }
        cameraView.didClose = { [weak self] in
            self?._didFinishPicking?(nil, true)
        }
        viewControllers = [cameraView]
    }
}
