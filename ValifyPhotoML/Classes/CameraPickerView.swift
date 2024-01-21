//
//  CamerPickerView.swift
//  ValifyPhotoML
//
//  Created by Esraa on 20/01/2024.
//

import UIKit
import AVFoundation

class CameraPickerView: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// delegates
    public var didClose:(() -> Void)?
    public var didPickPhoto: ((UIImage?) -> Void)?
    
    /// Settings
    let captureSession = AVCaptureSession()
    let output = AVCapturePhotoOutput()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    
    /// ShutterButton
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    /// CancelButton
    private let cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// check permissions
        checkCameraPermissions()
        //        prepareCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setUpView() {
        /// setup the view
        view.backgroundColor = .black
        view.addSubview(shutterButton)
        view.addSubview(cancelButton)
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
        cancelButton.center = CGPoint(x: 50, y: view.frame.size.height - 100)
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.didClose?()
                    }
                    return
                }
                DispatchQueue.main.async {
                    self?.prepareCamera()
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                self.prepareCamera()
            }
        case .denied, .restricted:
            didClose?()
        @unknown default:
            break
        }
    }
}

//MARK: - ACTIONS -

extension CameraPickerView {
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc private func didCancel() {
        didClose?()
    }
}

//MARK: - AVCapturePhotoCaptureDelegate -

extension CameraPickerView: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("-")
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {return}
        
        let image = UIImage(data: data)
        self.stopCapureSession()
        
        /// Preview Picked Image
        let previewPhotoView = PreviewPhotoView.initWith(image)
        previewPhotoView.didConfirmPhoto = { [weak self] img in
            self?.didPickPhoto?(img)
        }
        navigationController?.pushViewController(previewPhotoView, animated: false)
    }
    
    func stopCapureSession() {
        /// Stop Session
        captureSession.stopRunning()
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
}

extension CameraPickerView {
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first {
            captureDevice = availableDevice
            beginSession()
        }
    }
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        }catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        captureSession.commitConfiguration()
        
        //        let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
        //        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
}
