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
                // Use custom full-screen video player (no letterboxing)
                FullScreenVideoPlayer(player: player)
                    .ignoresSafeArea()
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
        // Try multiple paths - folder structure may or may not be preserved in bundle
        let videoPath: String? = 
            Bundle.main.path(forResource: "splash_video", ofType: "mp4", inDirectory: "Videos") ??
            Bundle.main.path(forResource: "splash_video", ofType: "mp4")
        
        #if DEBUG
        // Debug: list bundle contents to verify video is included
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                print("📦 Bundle root contents: \(contents)")
            }
            let videosPath = resourcePath + "/Videos"
            if let videosContents = try? fileManager.contentsOfDirectory(atPath: videosPath) {
                print("📦 Videos folder contents: \(videosContents)")
            } else {
                print("📦 No Videos folder found in bundle")
            }
        }
        #endif
        
        guard let videoPath = videoPath else {
            print("⚠️ splash_video.mp4 not found in bundle")
            // If video not found, skip splash after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isComplete = true
            }
            return
        }
        
        print("✅ Found video at: \(videoPath)")
        
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

// MARK: - Full Screen Video Player (no black bars)

/// Custom video player that fills the entire screen using AVPlayerLayer with .resizeAspectFill
struct FullScreenVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }
}

/// UIView wrapper for AVPlayerLayer with aspectFill
class PlayerUIView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        // This is the key - fill the screen, cropping edges if needed
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = UIColor.black.cgColor
    }
}
