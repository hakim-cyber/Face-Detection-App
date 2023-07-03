//
//  ContentView.swift
//  Video Editing
//
//  Created by aplle on 7/3/23.
//

import SwiftUI
import AVKit


struct ContentView: View {
    
    @State private var image:UIImage = UIImage(named: "faces")!
    
    @ObservedObject var faceDetector = DetectFaces()
    var body: some View {
        VStack{
            Spacer()
            if faceDetector.outputImage != nil{
                Image(uiImage: faceDetector.outputImage!)
                    .resizable()
                    .scaledToFit()
            }else{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            Button("Process"){
                faceDetector.image = image
                faceDetector.detectFaces(in: image)
            }
            .buttonStyle(.borderedProminent)
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
