import SwiftUI

struct DepthVideoView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool

    func makeUIViewController(context: Context) -> DepthVideoViewController {
        let controller = DepthVideoViewController()
        controller.onRecordingStateChanged = { recording in
            DispatchQueue.main.async {
                isRecording = recording
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: DepthVideoViewController, context: Context) {
        // Sync SwiftUI state with UIKit if needed
    }
}


