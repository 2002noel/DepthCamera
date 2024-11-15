//
//  CameraView.swift
//  DepthCamera
//
//  Created by noel kim on 11/15/24.
//


import AVFoundation
import SwiftUI


struct CameraView: View {
    @EnvironmentObject var cameraModel: CameraModel
    
    var body: some View{
        GeometryReader{proxy in
            let size = proxy.size
            
            cameraModelPreview(cameraModel: cameraModel)
                .environmentObject(cameraModel)
        }
        .onAppear{
                cameraModel.checkPermission()
            }
        .alert(isPresented: $cameraModel.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
        
    }
    
    
}

struct cameraModelPreview: UIViewRepresentable{
    @ObservedObject var cameraModel : CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
        cameraModel.preview.frame = view.frame
        cameraModel.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraModel.preview)
        
        cameraModel.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}


