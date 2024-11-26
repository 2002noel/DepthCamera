import SwiftUI

struct ContentView: View {
    @State private var isRecording = false

    var body: some View {
        ZStack {
            DepthVideoView(isRecording: $isRecording)
                .background(Color.black)
                //filling the screen
                
                
            VStack{
                Spacer()
                Button(action: {
                    isRecording.toggle()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .foregroundColor(.white)
                        .padding()
                        .background(isRecording ? Color.red : Color.green)
                        .cornerRadius(8)
                    
                }
                .padding()
            }
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

