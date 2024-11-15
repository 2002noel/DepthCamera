import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("frame")
    
    @State private var scale: CGFloat = 1.0
    @StateObject private var frameManager = FrameManager()
    
    private let zoomSpeed: CGFloat = 0.1
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(image, scale: 1.0, orientation: .up, label: label)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(scale) // Apply the scale to the image
                
                
                //record
                Button(action: {
                    print("takingvideo")
                }) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                }
            } else {
                Color.black
                
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let newScale = value * scale
                    let zoomFactor = max(1.0, min(newScale, 5.0)) // Cap the zoom factor to prevent excessive zooming
                    let smoothedZoom = scale + (zoomFactor - scale) * zoomSpeed // Apply smoothing
                    scale = smoothedZoom
                    frameManager.setZoomFactor(smoothedZoom)
                }
                .onEnded { _ in
                    
                    scale = frameManager.Zoom // Update scale with the last zoom factor
                }
        )
        .onAppear {
            
            frameManager.checkPermission()
            frameManager.setZoomFactor(1.0)
            frameManager.startSession()// Initialize zoom to 1
        }
        .onDisappear {
            frameManager.stopSession()
        }
    }
}
#Preview {
    FrameView()
}
