//
//  FruitSpawner.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import RealityKit
import Combine

class FruitSpawner {
    private var fruits: [FruitType: FruitEntity] = [:]
    private var updateSubscription: Cancellable?
    private weak var scene: RealityKit.Scene?
    private weak var cameraAnchor: AnchorEntity?
    
    func setup(in scene: RealityKit.Scene) {
        self.scene = scene
        
        print("🍎 DEBUG: Setting up fruit spawner")
        
        // Create world anchor with manual camera tracking
        let fruitAnchor = AnchorEntity(world: .zero)
        scene.addAnchor(fruitAnchor)
        self.cameraAnchor = fruitAnchor
        
        print("🍎 DEBUG: Fruit anchor created at position: \(fruitAnchor.position)")
        
        // Spawn one fruit of each type
        let allTypes = FruitType.allCases
        for (index, type) in allTypes.enumerated() {
            spawnFruit(type: type, at: index, parent: fruitAnchor)
        }
        
        print("🍎 DEBUG: Spawned \(fruits.count) fruits")
    }
    
    private func spawnFruit(type: FruitType, at index: Int, parent: Entity) {
        let fruit = FruitEntity(fruitType: type)
        
        // Panel layout: compact thumbnails at bottom of screen
        let spacing: Float = 0.04  // 4cm between thumbnails (narrower panel)
        let totalWidth = Float(FruitType.allCases.count - 1) * spacing
        let startX = -totalWidth / 2
        let xPosition = startX + Float(index) * spacing
        
        // Position for bottom panel:
        // X: horizontal spread (centered)
        // Y: bottom of view (-0.12m below camera center for panel)
        // Z: close to camera (-0.25m in front)
        fruit.position = SIMD3<Float>(xPosition, -0.12, -0.25)
        
        parent.addChild(fruit)
        fruits[type] = fruit
        
        print("🍎 DEBUG: Spawned \(type.rawValue) thumbnail at \(fruit.position)")
    }
    
    // Update fruit positions to stay at screen bottom relative to camera
    func updateFruitPositions(cameraTransform: Transform) {
        let cameraPosition = cameraTransform.translation
        
        // Get camera vectors for proper panel positioning
        let cameraForward = -SIMD3<Float>(
            cameraTransform.matrix.columns.2.x,
            cameraTransform.matrix.columns.2.y,
            cameraTransform.matrix.columns.2.z
        )
        let cameraRight = SIMD3<Float>(
            cameraTransform.matrix.columns.0.x,
            cameraTransform.matrix.columns.0.y,
            cameraTransform.matrix.columns.0.z
        )
        let cameraUp = SIMD3<Float>(
            cameraTransform.matrix.columns.1.x,
            cameraTransform.matrix.columns.1.y,
            cameraTransform.matrix.columns.1.z
        )
        
        let allTypes = FruitType.allCases
        for (index, type) in allTypes.enumerated() {
            guard let fruit = fruits[type] else { continue }
            
            // Skip if fruit is being dragged (gesture handler controls position)
            if fruit.isBeingDragged {
                continue
            }
            
            // Skip if fruit is currently being thrown (dynamic mode)
            if let physics = fruit.components[PhysicsBodyComponent.self],
               physics.mode == .dynamic {
                // Check respawn
                if shouldRespawn(fruit, cameraPosition: cameraPosition) {
                    respawnFruit(fruit)
                }
                continue
            }
            
            // Panel layout: compact spacing for thumbnails
            let spacing: Float = 0.04  // 4cm between thumbnails (narrower panel)
            let totalWidth = Float(allTypes.count - 1) * spacing
            let startX = -totalWidth / 2
            let xOffset = startX + Float(index) * spacing
            
            // Position relative to camera view:
            // In portrait mode on iOS:
            // - cameraUp = screen horizontal (left/right)
            // - cameraRight = screen vertical (down is positive)
            let forwardOffset = cameraForward * 0.25
            let horizontalOffset = cameraUp * xOffset       // Spread left-right using cameraUp
            let verticalOffset = cameraRight * 0.12         // Move down using cameraRight
            let worldPosition = cameraPosition + forwardOffset + horizontalOffset + verticalOffset
            
            fruit.setPosition(worldPosition, relativeTo: nil)
            
            // Orient plane to face camera (plane's +Z should point toward camera)
            // look(at:) points -Z toward target, so we look AWAY from camera
            let awayFromCamera = worldPosition + (worldPosition - cameraPosition)
            fruit.look(at: awayFromCamera, from: worldPosition, relativeTo: nil)
            
            // Debug logging disabled - uncomment if needed
            // if index == 0 && Int.random(in: 0..<60) == 0 {
            //     print("🍎 DEBUG: Panel banana at \(worldPosition), camera at \(cameraPosition)")
            // }
        }
    }
    
    private func shouldRespawn(_ fruit: FruitEntity, cameraPosition: SIMD3<Float>) -> Bool {
        // Respawn if fruit is too far away (fallen out of view or too far)
        let distance = simd_distance(fruit.position, cameraPosition)
        return distance > 3.0  // 3 meters
    }
    
    private func respawnFruit(_ fruit: FruitEntity) {
        // Reset to thumbnail size and kinematic physics
        fruit.resetToThumbnail()
        
        // Position will be updated on next frame by updateFruitPositions
        print("🍎 DEBUG: Respawned \(fruit.fruitType.rawValue) as thumbnail")
    }
    
    // Get fruit at touch position
    func getFruitAt(worldPosition: SIMD3<Float>) -> FruitEntity? {
        var closestFruit: FruitEntity?
        var closestDistance: Float = Float.greatestFiniteMagnitude
        
        for (_, fruit) in fruits {
            let distance = simd_distance(fruit.position, worldPosition)
            if distance < closestDistance && distance < 0.1 {  // Within 10cm
                closestDistance = distance
                closestFruit = fruit
            }
        }
        
        return closestFruit
    }
    
    func removeAllFruits() {
        for (_, fruit) in fruits {
            fruit.removeFromParent()
        }
        fruits.removeAll()
    }
}
