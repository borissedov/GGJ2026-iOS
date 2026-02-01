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
    @Published var hasDetectedImage: Bool = false  // True after first detection, stays true
    
    // Separate counters for each fruit type
    @Published var bananaCount: Int = 0
    @Published var peachCount: Int = 0
    @Published var coconutCount: Int = 0
    @Published var watermelonCount: Int = 0
    
    // Multiplayer properties
    @Published var networkState: NetworkGameState?
    @Published var currentOrder: OrderDisplay?
    @Published var isInMultiplayerMode: Bool = false
    
    private var collisionSubscription: Cancellable?
    private var hitFruits: Set<ObjectIdentifier> = []
    
    // Haptic feedback generator
    private var hapticGenerator: UIImpactFeedbackGenerator?
    
    // Multiplayer
    private var signalRClient: SignalRClient?
    private var currentRoomId: UUID?
    
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
            
            if isInMultiplayerMode {
                // Report to server
                Task { [weak self] in
                    guard let self = self,
                          let roomId = self.currentRoomId,
                          let client = self.signalRClient else { return }
                    
                    let hitId = UUID()
                    do {
                        try await client.reportHit(
                            roomId: roomId,
                            hitId: hitId,
                            fruitType: fruit.fruitType
                        )
                        print("🎯 Reported hit: \(fruit.fruitType)")
                    } catch {
                        print("❌ Failed to report hit: \(error)")
                    }
                }
            } else {
                // Local scoring (existing logic)
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
    
    // MARK: - Multiplayer Integration
    
    func enableMultiplayer(signalRClient: SignalRClient, roomId: UUID) {
        self.signalRClient = signalRClient
        self.currentRoomId = roomId
        self.isInMultiplayerMode = true
        
        print("✅ Multiplayer enabled for room: \(roomId)")
    }
    
    func handleStateSnapshot(_ snapshot: StateSnapshotEvent) {
        networkState = NetworkGameState(from: snapshot)
        
        if let order = snapshot.currentOrder {
            // Convert to OrderDisplay (requires OrderStartedEvent structure)
            // This is a simplified conversion
            print("📦 Received current order")
        }
    }
    
    func handleOrderStarted(_ event: OrderStartedEvent) {
        currentOrder = OrderDisplay(from: event)
        print("🎯 New order started: \(event.orderNumber)")
    }
    
    func handleOrderTotalsUpdated(_ event: OrderTotalsUpdatedEvent) {
        currentOrder?.updateSubmitted(event)
        print("📊 Order totals updated")
    }
    
    deinit {
        collisionSubscription?.cancel()
    }
}
