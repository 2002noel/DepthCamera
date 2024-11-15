import Foundation
import AVFoundation
import CoreImage

class FrameManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var frame: CGImage?
    private var Permission = false
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let context = CIContext()
    private let output = AVCapturePhotoOutput()
    
    private var videoDevice: AVCaptureDevice?
    @Published var Zoom: CGFloat = 1.0
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async {
            self.setupSession()
        }
    }
    
    func checkPermission() {
        print("Checking permission")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            Permission = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.Permission = true
                    self.setupSession()
                }
            }
        default:
            break
        }
    }
    
    func setZoomFactor(_ factor: CGFloat) {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
            self.Zoom = device.videoZoomFactor
        } catch {
            print("Failed to set zoom factor: \(error)")
        }
    }
    
    func setupSession() {
        guard !session.isRunning else { return }
        guard Permission else { return }
        
        let videooutput = AVCaptureVideoDataOutput()
        
        guard let videodevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        self.videoDevice = videodevice
        
        guard let videoinput = try? AVCaptureDeviceInput(device: videodevice) else { return }
        guard session.canAddInput(videoinput) else { return }
        session.addInput(videoinput)
        
        guard session.canAddOutput(videooutput) else { return }
        videooutput.setSampleBufferDelegate(self, queue: sessionQueue)
        session.addOutput(videooutput)
        
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        
        // Set orientation
        if let connection = videooutput.connection(with: .video) {
            connection.videoRotationAngle = 90
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelbuffer = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async {
            self.frame = pixelbuffer
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let pixelbuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciimage = CIImage(cvPixelBuffer: pixelbuffer)
        guard let cgImage = context.createCGImage(ciimage, from: ciimage.extent) else { return nil }
        return cgImage
    }
}
