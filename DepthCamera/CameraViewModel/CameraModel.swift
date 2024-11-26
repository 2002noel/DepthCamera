//
//  CameraModel.swift
//  DepthCamera
//
//  Created by noel kim on 11/15/24.
//

import AVFoundation
import SwiftUI



class CameraModel: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject, AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error = error{
            print(error.localizedDescription)
            return
        }
        print(outputFileURL)
    }
    
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    @Published var isRecording: Bool = false
    @Published var recordURL : [URL] = []
    
    func checkPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status{
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
        default:
            return
        }
    }
    
    func setUp(){
        
        do{
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else {return}
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(output){
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
            
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func startRecording(){
        let tempURL = NSTemporaryDirectory() + "tempMovie.mov"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording(){
        output.stopRecording()
        isRecording = false
    }
        
    }
    


