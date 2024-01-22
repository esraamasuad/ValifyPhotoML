//
//  FaceDetection+extension.swift
//  ValifyPhotoML
//
//  Created by Esraa on 21/01/2024.
//

import Vision
//import Foundation

//MARK: - Face-Detection -

extension CameraPickerView {
    
    func detectFace(image: CVPixelBuffer, completion: @escaping ((_ isFace:Bool) -> ())) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
//                    print("✅ Detected \(results.count) faces!")
                    self.handleFaceDetectionResults(observedFaces: results)
                    completion(true)
                } else {
//                    print("❌ No face was detected")
                    self.clearDrawings()
                    completion(false)
                }
            }
        }
        
        let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageResultHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(observedFaces: [VNFaceObservation]) {
        clearDrawings()
        
        // Create the boxes
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
            
            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            
            // Set properties of the box shape
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            
            return faceBoundingBoxShape
        })
        
        // Add boxes to the view layer and the array
        facesBoundingBoxes.forEach { faceBoundingBox in
            view.layer.addSublayer(faceBoundingBox)
            drawings = facesBoundingBoxes
        }
    }
    
    private func clearDrawings() {
        drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
}
