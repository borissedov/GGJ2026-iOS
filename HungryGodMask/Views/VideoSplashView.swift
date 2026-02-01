//
//  VideoSplashView.swift
//  HungryGodMask
//
//  Video splash screen that continues from static splash
//

import SwiftUI
import AVKit

struct VideoSplashView: View {
    @Binding var isComplete: Bool
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .disabled(true) // Disable controls
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        // Try to load video from bundle
        guard let videoPath = Bundle.main.path(forResource: "splash_video", ofType: "mp4") else {
            // If video not found, skip splash after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isComplete = true
            }
            return
        }
        
        let url = URL(fileURLWithPath: videoPath)
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe when video finishes
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            isComplete = true
        }
        
        // Auto-play
        player?.play()
    }
}
