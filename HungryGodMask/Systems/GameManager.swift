//
//  GameManager.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import RealityKit
import Combine
import UIKit

class GameManager: ObservableObject {
    @Published var score: Int = 0
    @Published var isTracking: Bool = false
    
    // Separate counters for each fruit type
    @Published var bananaCount: Int = 0
    @Published var peachCount: Int = 0
    @Published var coconutCount: Int = 0
    @Published var watermelonCount: Int = 0
    
    private var collisionSubscription: Cancellable?
    private var hitFruits: Set<ObjectIdentifier> = []
    
    // Haptic feedback generator
    private var hapticGenerator: UIImpactFeedbackGenerator?
    
    init() {
        // Initialize haptic feedback (may not be available on all devices)
        if UIDevice.current.userInterfaceIdiom == .phone {
            hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
            hapticGenerator?.prepare()
        }
    }
    
    // Subscribe to collision events
    func setupCollisionDetection(for scene: RealityKit.Scene) {
        collisionSubscription = scene.subscribe(
            to: CollisionEvents.Began.self,
            on: nil
        ) { [weak self] event in
            self?.handleCollision(event)
        }
    }
    
    private func handleCollision(_ event: CollisionEvents.Began) {
        // Check if one of the entities is a fruit and the other is the gate
        let entityA = event.entityA
        let entityB = event.entityB
        
        var fruit: FruitEntity?
        var isGate = false
        
        // Determine which entity is the fruit and which is the gate
        if let fruitA = entityA as? FruitEntity, entityB is MouthGateEntity {
            fruit = fruitA
            isGate = true
        } else if let fruitB = entityB as? FruitEntity, entityA is MouthGateEntity {
            fruit = fruitB
            isGate = true
        }
        
        // Process the hit
        if isGate, let fruit = fruit {
            let fruitID = ObjectIdentifier(fruit)
            
            // Only count each fruit once
            guard !hitFruits.contains(fruitID) else { return }
            hitFruits.insert(fruitID)
            
            // Increment score and fruit-specific counter
            DispatchQueue.main.async { [weak self] in
                self?.score += 1
                
                // Increment fruit-specific counter
                switch fruit.fruitType {
                case .banana:
                    self?.bananaCount += 1
                case .peach:
                    self?.peachCount += 1
                case .coconut:
                    self?.coconutCount += 1
                case .watermelon:
                    self?.watermelonCount += 1
                }
                
                // Trigger haptic feedback (if available)
                self?.hapticGenerator?.impactOccurred()
            }
            
            // Optional: Visual/audio feedback
            playHitFeedback()
            
            // Mark fruit for respawn after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.hitFruits.remove(fruitID)
            }
        }
    }
    
    private func playHitFeedback() {
        // Optional: Play sound effect
        // AudioServicesPlaySystemSound(SystemSoundID(1103))
    }
    
    func resetScore() {
        score = 0
        bananaCount = 0
        peachCount = 0
        coconutCount = 0
        watermelonCount = 0
        hitFruits.removeAll()
    }
    
    deinit {
        collisionSubscription?.cancel()
    }
}
