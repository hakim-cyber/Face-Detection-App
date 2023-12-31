//
//  features.swift
//  Video Editing
//
//  Created by aplle on 7/3/23.
//

import Foundation

import AVKit
import Vision
import UIKit
import SwiftUI


class DetectFaces:ObservableObject{
    var image:UIImage = UIImage()
    
    @Published var outputImage:UIImage?
    
    private var detectedFaces:[VNFaceObservation] = [VNFaceObservation()]
    
    func detectFaces(in image:UIImage){
        guard let ciimage = CIImage(image: image)else{
            fatalError("Couldnt covert image to ciimage")
        }
        let request = VNDetectFaceRectanglesRequest(completionHandler: self.handleFacesData)
        
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
    
        let handler = VNImageRequestHandler(ciImage: ciimage,options: [:])
        
        do{
            try handler.perform([request])
            
            
        }catch let requestErr{
            print(("failed to perform request \(requestErr)"))
        }
        
        
        
        
    }
    func handleFacesData(request:VNRequest,error:Error?){
        DispatchQueue.main.async {
            guard let results = request.results as? [VNFaceObservation] else{
                return
            }
            self.detectedFaces = results
            for faces in self.detectedFaces{
                self.addRectToImage(result: faces)
            }
            self.outputImage = self.image
        }
    }
    func addRectToImage(result:VNFaceObservation){
        let imageSize = CGSize(width: image.size.width, height: image.size.height)
        
        let boundingBox = result.boundingBox
        
        let scaledBox = CGRect(
            x:boundingBox.origin.x * imageSize.width,
            y:(1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height,
            width: boundingBox.size.width * imageSize.width,
            height: boundingBox.size.height * imageSize.height
        )
        
        let normalizedRect = VNNormalizedRectForImageRect(scaledBox, Int(imageSize.width), Int(imageSize.height))
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemGray4.cgColor)
        context?.fill(CGRect(x: normalizedRect.origin.x * imageSize.width
                             , y: normalizedRect.origin.y * imageSize.height
                             , width: normalizedRect.size.width * imageSize.width
                             , height:  normalizedRect.size.height * imageSize.height))
        
        
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
}


import Foundation
import PhotosUI
import SwiftUI


struct ImagePicker:UIViewControllerRepresentable{
    @Binding var image:UIImage?
    class Coordinator:NSObject,PHPickerViewControllerDelegate{
        
        var parent:ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else{return}
            
            if provider.canLoadObject(ofClass: UIImage.self){
                provider.loadObject(ofClass: UIImage.self){ image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
        
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
