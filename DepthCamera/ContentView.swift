//
//  ContentView.swift
//  DepthCamera
//
//  Created by noel kim on 11/12/24.
//

import SwiftUI
//depth camera



struct ContentView: View {
    @StateObject private var model = FrameManager()
    var body: some View {
        FrameView(image: model.frame)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
