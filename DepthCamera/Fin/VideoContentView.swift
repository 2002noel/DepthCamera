
import Aespa
import SwiftUI

struct VideoContentView: View {
    @State var isRecording = false
    @State var isFront = false
    @State var showSetting = false
    
    @State var captureMode: AssetType = .video
    
    @ObservedObject private var viewModel = VideoContentViewModel()
    
    var body: some View {
        ZStack {
            viewModel.preview
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                    //Button
                    recordingButtonShape(width: 60).onTapGesture {
                            if isRecording {
                                viewModel.aespaSession.stopRecording()
                                isRecording = false
                            } else {
                                viewModel.aespaSession.startRecording(autoVideoOrientationEnabled: true)
                                isRecording = true
                            }
                        }
                    
                }
            }
    }
}

extension VideoContentView {
    @ViewBuilder
    func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 1)
            )
            .padding(20)
    }
    
    @ViewBuilder
    func recordingButtonShape(width: CGFloat) -> some View {
        ZStack {
            Circle()
                .strokeBorder(isRecording ? .red : .white, lineWidth: 3)
                .frame(width: width)
            
            Circle()
                .fill(isRecording ? .red : .white)
                .frame(width: width * 0.8)
        }
        .frame(height: width)
    }
}

enum AssetType {
    case video
}

struct VideoContentView_Previews: PreviewProvider {
    static var previews: some View {
        VideoContentView()
    }
}
