import UIKit
import AVFoundation

class DepthVideoViewController: UIViewController {
    var previewView: UIImageView = UIImageView()
    let session = AVCaptureSession()
    let dataOutputQueue = DispatchQueue(label: "video data queue", qos: .userInitiated)
    var depthMap: CIImage?

    // Video Recording
    var assetWriter: AVAssetWriter?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var videoInput: AVAssetWriterInput?
    var isRecording = false
    var startTime: CMTime?

    // Communicating with SwiftUI
    var onRecordingStateChanged: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePreviewView()
        //make it full screen
        previewView.contentMode = .scaleAspectFill
        //change gravity to resize
        previewView.layer.contentsGravity = .resizeAspectFill
        configureCaptureSession()
        session.startRunning()
    }

    private func configurePreviewView() {
        previewView.contentMode = .scaleAspectFit
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .unspecified) else {
            fatalError("No depth video camera available")
        }

        session.sessionPreset = .photo

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }

        let depthOutput = AVCaptureDepthDataOutput()
        depthOutput.setDelegate(self, callbackQueue: dataOutputQueue)
        depthOutput.isFilteringEnabled = true
        session.addOutput(depthOutput)

        let depthConnection = depthOutput.connection(with: .depthData)
        depthConnection?.videoOrientation = .portrait
    }

    func startRecording() {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("depthVideo.mov")
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 720,
                AVVideoHeightKey: 1280
            ])
            guard let videoInput = videoInput else { return }

            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoInput,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                    kCVPixelBufferWidthKey as String: 720,
                    kCVPixelBufferHeightKey as String: 1280
                ]
            )

            if assetWriter!.canAdd(videoInput) {
                assetWriter!.add(videoInput)
            } else {
                fatalError("Cannot add video input to asset writer")
            }

            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: .zero)

            isRecording = true
            startTime = nil
            onRecordingStateChanged?(true)

        } catch {
            fatalError("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        isRecording = false

        videoInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            guard let self = self else { return }
            if let outputURL = self.assetWriter?.outputURL {
                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            }
            self.onRecordingStateChanged?(false)
        }
    }
}

// MARK: - AVCaptureDepthDataOutputDelegate
extension DepthVideoViewController: AVCaptureDepthDataOutputDelegate {
    func depthDataOutput(_ output: AVCaptureDepthDataOutput,
                         didOutput depthData: AVDepthData,
                         timestamp: CMTime,
                         connection: AVCaptureConnection) {
        var convertedDepth: AVDepthData

        let depthDataType = kCVPixelFormatType_DisparityFloat32
        if depthData.depthDataType != depthDataType {
            convertedDepth = depthData.converting(toDepthDataType: depthDataType)
        } else {
            convertedDepth = depthData
        }

        let pixelBuffer = convertedDepth.depthDataMap
        let depthMap = CIImage(cvPixelBuffer: pixelBuffer)
        
        DispatchQueue.main.async { [weak self] in
            self?.depthMap = depthMap
            self?.previewView.image = UIImage(ciImage: depthMap)
        }

        // Record depth map if recording
        if isRecording {
            if startTime == nil { startTime = timestamp }
            let timeSinceStart = CMTimeSubtract(timestamp, startTime!)

            guard let pixelBufferAdaptor = pixelBufferAdaptor,
                  pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData else {
                return
            }

            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: timeSinceStart)
        }
    }
}
