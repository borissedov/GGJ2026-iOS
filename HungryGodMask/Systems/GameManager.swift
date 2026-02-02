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
    @Published var isGameOver: Bool = false
    @Published var gameResults: String?
    
    private var collisionSubscription: Cancellable?
    private var hitFruits: Set<ObjectIdentifier> = []
    
    // Haptic feedback generator
    private var hapticGenerator: UIImpactFeedbackGenerator?
    
    // Multiplayer
    private var signalRClient: SignalRClient?
    private var currentRoomId: UUID?
    
    // Reference to fruit spawner for randomization
    private weak var fruitSpawner: FruitSpawner?
    
    // Order countdown timer
    private var orderTimer: Timer?
    
    init() {
        // Initialize haptic feedback (may not be available on all devices)
        if UIDevice.current.userInterfaceIdiom == .phone {
            hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
            hapticGenerator?.prepare()
        }
    }
    
    // Subscribe to collision events
    func setupCollisionDetection(for scene: RealityKit.Scene) {
        print("🎯 Setting up collision detection for scene")
        collisionSubscription = scene.subscribe(
            to: CollisionEvents.Began.self,
            on: nil
        ) { [weak self] event in
            self?.handleCollision(event)
        }
        print("🎯 Collision subscription created: \(collisionSubscription != nil)")
    }
    
    private func handleCollision(_ event: CollisionEvents.Began) {
        // Check if one of the entities is a fruit and the other is the gate
        let entityA = event.entityA
        let entityB = event.entityB
        
        // Debug: Log all collisions
        print("💥 Collision detected: \(type(of: entityA)) vs \(type(of: entityB))")
        
        var fruit: FruitEntity?
        var isGate = false
        
        // Determine which entity is the fruit and which is the gate
        if let fruitA = entityA as? FruitEntity, entityB is MouthGateEntity {
            fruit = fruitA
            isGate = true
            print("💥 Fruit-Gate collision! Fruit: \(fruitA.fruitType)")
        } else if let fruitB = entityB as? FruitEntity, entityA is MouthGateEntity {
            fruit = fruitB
            isGate = true
            print("💥 Fruit-Gate collision! Fruit: \(fruitB.fruitType)")
        }
        
        // Process the hit
        if isGate, let fruit = fruit {
            let fruitID = ObjectIdentifier(fruit)
            
            // Only count each fruit once
            guard !hitFruits.contains(fruitID) else { 
                print("💥 Duplicate hit ignored for \(fruit.fruitType)")
                return 
            }
            hitFruits.insert(fruitID)
            
            print("💥 Processing hit - Multiplayer: \(isInMultiplayerMode), RoomId: \(currentRoomId?.uuidString ?? "nil"), Client: \(signalRClient != nil)")
            
            if isInMultiplayerMode {
                // Report to server
                Task { [weak self] in
                    guard let self = self,
                          let roomId = self.currentRoomId,
                          let client = self.signalRClient else { 
                        print("❌ Missing multiplayer components - roomId: \(self?.currentRoomId?.uuidString ?? "nil"), client: \(self?.signalRClient != nil)")
                        return 
                    }
                    
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
        // Play hit sound
        SoundManager.shared.playHit()
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
        
        // Randomize fruit panel order for this order
        fruitSpawner?.randomizeFruitOrder()
        
        // Start countdown timer
        startOrderTimer()
    }
    
    private func startOrderTimer() {
        // Cancel any existing timer
        orderTimer?.invalidate()
        
        // Create timer that fires every second
        orderTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if var order = self.currentOrder, order.timeRemaining > 0 {
                    order.timeRemaining -= 1
                    self.currentOrder = order
                    // print("⏱️ Order time: \(order.timeRemaining)s")
                }
            }
        }
    }
    
    private func stopOrderTimer() {
        orderTimer?.invalidate()
        orderTimer = nil
    }
    
    // Called from ARImageTrackingView to pass FruitSpawner reference
    func setFruitSpawner(_ spawner: FruitSpawner) {
        self.fruitSpawner = spawner
    }
    
    func handleOrderTotalsUpdated(_ event: OrderTotalsUpdatedEvent) {
        // Must run on main thread to trigger @Published update
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Must unwrap, mutate, and reassign to trigger @Published update
            if var order = self.currentOrder {
                order.updateSubmitted(event)
                self.currentOrder = order
                print("📊 Order totals updated on main thread: \(order.submitted)")
            }
        }
    }
    
    func handleGameFinished(successCount: Int, failCount: Int) {
        stopOrderTimer()
        isGameOver = true
        gameResults = "Game Complete! ✅ \(successCount) successes, ❌ \(failCount) failures"
        print("🎉 Game finished: \(gameResults ?? "")")
    }
    
    func handleGameOver(reason: String) {
        stopOrderTimer()
        isGameOver = true
        gameResults = reason
        print("💀 Game over: \(reason)")
    }
    
    func handleOrderResolved() {
        // Stop timer when order ends
        stopOrderTimer()
    }
    
    func restartGame() {
        // Stop any running timers
        stopOrderTimer()
        
        // Reset all game state
        resetScore()
        isGameOver = false
        gameResults = nil
        currentOrder = nil
        networkState = nil
        
        // Disconnect from current room
        signalRClient?.disconnect()
        signalRClient = nil
        currentRoomId = nil
        isInMultiplayerMode = false
        
        print("🔄 Game restarted")
    }
    
    deinit {
        collisionSubscription?.cancel()
        orderTimer?.invalidate()
    }
}
