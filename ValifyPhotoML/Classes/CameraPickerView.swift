//
//  CamerPickerView.swift
//  ValifyPhotoML
//
//  Created by Esraa on 20/01/2024.
//

import UIKit
import AVFoundation

class CameraPickerView: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Variables -
    
    /// delegates
    public var didClose:(() -> Void)?
    public var didPickPhoto: ((UIImage?) -> Void)?
    
    /// Settings
    var drawings: [CAShapeLayer] = []
    private let captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer!
    private var captureDevice:AVCaptureDevice!
    
    private let videoDataOutput = AVCaptureVideoDataOutput()
        
    private var isTakePhoto = false
    
    /// ShutterButton
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    /// CancelButton
    fileprivate let cancelButton: UIButton = {
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
        isTakePhoto = true
    }
    
    @objc private func didCancel() {
        didClose?()
    }
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate -

extension CameraPickerView: AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("captureOutput => ")
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Unable to get image from the sample buffer")
            return
        }
        
        /// detect the captured face
        detectFace(image: frame, completion: { [weak self] isFace in
            if self!.isTakePhoto {
                self!.isTakePhoto = false
                
                if !isFace { return }
                
                // importat: - Stop the session
                self?.stopCapureSession()
                
                DispatchQueue.main.async {
                    //get a CIImage out of the CVImageBuffer
                    let ciImage = CIImage(cvImageBuffer: frame)
                    let image = UIImage(ciImage: ciImage)
                    
                    /// Preview Picked Image
                    let previewPhotoView = PreviewPhotoView.initWith(image)
                    previewPhotoView.didConfirmPhoto = { [weak self] img in
                        self?.didPickPhoto?(img)
                    }
                    self?.navigationController?.pushViewController(previewPhotoView, animated: false)
                }
            }
        })
    }
}

//MARK: - Camera Settings -

extension CameraPickerView {
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first {
            captureDevice = availableDevice
            beginSession()
        }
    }
    
    func beginSession () {
        /// addInput
        getInputSettings()
        /// preview layer
        showCameraFeed()
        /// start session
        captureSession.startRunning()
        /// PreviewLayer
        getCameraFrames()
        
        captureSession.commitConfiguration()
    }
    
    private func getInputSettings() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    private func showCameraFeed() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
    }
    
    private func getCameraFrames() {
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        // You do not want to process the frames on the Main Thread so we off load to another thread
        let queue = DispatchQueue(label: "camera_frame_processing_queue")
        videoDataOutput.setSampleBufferDelegate(self, queue: queue)
        
        captureSession.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(with: .video), connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = true
    }
    
    /// Stop Session + remove input & output
    func stopCapureSession() {
        captureSession.stopRunning()
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
        if let outputs = captureSession.outputs as? [AVCaptureVideoDataOutput] {
            for output in outputs {
                self.captureSession.removeOutput(output)
            }
        }
    }
}
