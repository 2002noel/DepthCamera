//
//  ContentView.swift
//  DepthCamera
//
//  Created by noel kim on 11/12/24.
//

import SwiftUI
import AVKit
//depth camera



struct ContentView: View {
    @StateObject var cameraModel = CameraModel()
    
    
    var body: some View {
        VideoContentView()
    }
}


#Preview {
    ContentView()
}

struct finalContentView: View{
    var url: URL
    var body: some View{
        
        GeometryReader{ proxy in
            let size = proxy.size
            
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                
                
        }
    }
}
