import UIKit
import AVFoundation
import SwiftUI

class ViewController: UIViewController {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to \(fileURL)")
    }
    
    private var permission = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private var movieFileOutput: AVCaptureMovieFileOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()

        sessionQueue.async {
            [unowned self] in
            guard permission else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }

        // Observe orientation changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func orientationDidChange() {
        // Adjust the video orientation for the current device orientation
        guard let connection = previewLayer.connection else { return }

    
        connection.videoOrientation = currentVideoOrientation()
        
        
        self.adjustPreviewLayerFrame()
        
        previewLayer.frame = view.bounds
                
            
        

        // Adjust the preview layer frame for the new orientation
        adjustPreviewLayerFrame()
    }

    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft

        default:
            return .portrait
        }
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permission = true
        case .notDetermined:
            requestPermission()
        default:
            break
        }
    }

    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            if granted {
                self.permission = true
                self.sessionQueue.resume()
            }
        }
    }

    func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }

        captureSession.addInput(videoInput)
        
        let movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
            movieFileOutput = movieOutput
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill

        DispatchQueue.main.async { [unowned self] in
            self.view.layer.addSublayer(previewLayer)
            self.adjustPreviewLayerFrame() // Adjust the frame for the first time
            self.orientationDidChange() // Set the initial orientation
        }
    }
    
    func startRecording() {
        guard let movieOutput = movieFileOutput else { return }

        let outputDirectory = FileManager.default.temporaryDirectory
        let outputFilePath = outputDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")

    }

    func stopRecording() {
        movieFileOutput?.stopRecording()
    }

    private func adjustPreviewLayerFrame() {
        // Update the preview layer's frame to match the view's bounds
        previewLayer.frame = view.bounds

        let videoAspectRatio: CGFloat
        if let videoConnection = previewLayer.connection {
            if videoConnection.isVideoOrientationSupported {
                let videoWidth = previewLayer.bounds.width
                let videoHeight = previewLayer.bounds.height
                videoAspectRatio = videoWidth / videoHeight
            } else {
                // Default to a 16:9 aspect ratio
                videoAspectRatio = 16 / 9
            }
        } else {
            // Default to a 16:9 aspect ratio
            videoAspectRatio = 16 / 9
        }

        // Handle landscape and portrait differently
        if UIDevice.current.orientation.isLandscape {
            // Landscape orientation, adjust height according to aspect ratio
            let newHeight = view.bounds.width / videoAspectRatio
            previewLayer.frame = CGRect(x: 0, y: (view.bounds.height - newHeight) / 2, width: view.bounds.width, height: newHeight)
        } else if UIDevice.current.orientation.isPortrait {
            // Portrait orientation, adjust width according to aspect ratio
            let newWidth = view.bounds.height * videoAspectRatio
            previewLayer.frame = CGRect(x: (view.bounds.width - newWidth) / 2, y: 0, width: newWidth, height: view.bounds.height)
        }

        previewLayer.videoGravity = .resizeAspectFill
    }
    
}


struct HostedViewController: UIViewControllerRepresentable {
    private let viewController = ViewController()
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    
    func startRecording() {
            viewController.startRecording()
        }

        func stopRecording() {
            viewController.stopRecording()
        }
}
