//
//  SoundManager.swift
//  HungryGodMask
//
//  Sound effect manager using AVAudioPlayer
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadSounds() {
        let soundFiles = [
            "touch": "Sounds/touch",
            "throw": "Sounds/throw",
            "hit": "Sounds/hit",
            "miss": "Sounds/miss"
        ]
        
        for (key, filename) in soundFiles {
            // Try with Sounds/ prefix first
            var url = Bundle.main.url(forResource: filename, withExtension: "mp3")
            
            // If not found, try without prefix (in case files were added to root)
            if url == nil {
                let nameOnly = filename.replacingOccurrences(of: "Sounds/", with: "")
                url = Bundle.main.url(forResource: nameOnly, withExtension: "mp3")
                if url != nil {
                    print("ℹ️ Found sound at root: \(nameOnly).mp3")
                }
            }
            
            if let soundUrl = url {
                do {
                    let player = try AVAudioPlayer(contentsOf: soundUrl)
                    player.prepareToPlay()
                    player.volume = 1.0 // Ensure volume is at max
                    audioPlayers[key] = player
                    print("✅ Loaded sound: \(key) from \(soundUrl.lastPathComponent)")
                } catch {
                    print("❌ Failed to load sound \(key): \(error)")
                }
            } else {
                print("⚠️ Sound file not found in bundle: \(filename).mp3")
                print("   Tried: Sounds/\(key).mp3 and \(key).mp3")
            }
        }
        
        print("📊 Sound loading complete: \(audioPlayers.count)/4 sounds loaded")
    }
    
    func playTouch() {
        play("touch")
    }
    
    func playThrow() {
        play("throw")
    }
    
    func playHit() {
        play("hit")
    }
    
    func playMiss() {
        play("miss")
    }
    
    private func play(_ soundKey: String) {
        guard let player = audioPlayers[soundKey] else {
            print("⚠️ Sound not loaded: \(soundKey)")
            return
        }
        
        // Reset to beginning and play
        player.currentTime = 0
        let success = player.play()
        print("🔊 Playing sound: \(soundKey) - \(success ? "success" : "failed")")
    }
    
    func stopAll() {
        for player in audioPlayers.values {
            player.stop()
        }
    }
}
