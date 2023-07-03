//
//  ContentView.swift
//  Video Editing
//
//  Created by aplle on 7/3/23.
//

import SwiftUI
import AVKit


struct ContentView: View {
    
    @State private var image:UIImage?
    
    @ObservedObject var faceDetector = DetectFaces()
    @State private var showPicker = false
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                if faceDetector.outputImage != nil{
                    Image(uiImage: faceDetector.outputImage!)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            showPicker = true
                            faceDetector.outputImage = nil
                        }
                }else{
                    ZStack{
                        if image != nil{
                            Image(uiImage: image!)
                                .resizable()
                                .scaledToFit()
                        }else{
                            Image(uiImage: UIImage())
                                .resizable()
                                .scaledToFit()
                                .background(.gray)
                            ProgressView()
                        }
                    }
                    .onTapGesture {
                        showPicker = true
                    }
                }
                Spacer()
                Button("Process"){
                    if image != nil{
                        faceDetector.image = image!
                        faceDetector.detectFaces(in: image!)
                    }
                }
                .disabled(image == nil)
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Blur Faces")
            .sheet(isPresented: $showPicker){
                ImagePicker(image: $image)
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
