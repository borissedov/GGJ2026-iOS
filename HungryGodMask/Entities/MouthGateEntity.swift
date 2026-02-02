//
//  MouthGateEntity.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import RealityKit
import UIKit

class MouthGateEntity: Entity {
    
    // Offset from image anchor to mouth position
    // In AR Image Tracking: X=horizontal, Y=vertical(up/down), Z=depth(forward/back from screen)
    // Positive Y = up, Negative Y = down
    // The mask mouth is typically in the lower half, so we use negative Y to move DOWN
    static let defaultMouthOffset = SIMD3<Float>(0, -0.05, 0.05)  // 5cm down, 5cm forward from image
    
    // Gate dimensions (generous sizing to catch fruits)
    // Box parameters map to: width=X (horizontal), height=Y (vertical), depth=Z (forward/back)
    static let gateWidth: Float = 0.25   // 25cm wide (X axis - screen horizontal)
    static let gateHeight: Float = 0.20  // 20cm tall (Y axis - screen vertical)
    static let gateDepth: Float = 0.15   // 15cm deep (Z axis - toward/away from camera)
    
    required init(at offset: SIMD3<Float> = defaultMouthOffset) {
        super.init()
        
        self.position = offset
        setupCollisionGate()
    }
    
    required init() {
        super.init()
        self.position = MouthGateEntity.defaultMouthOffset
        setupCollisionGate()
    }
    
    private func setupCollisionGate() {
        // Create invisible collision trigger zone
        // Using a box shape for the mouth opening
        let shape = ShapeResource.generateBox(
            width: MouthGateEntity.gateWidth,
            height: MouthGateEntity.gateHeight,
            depth: MouthGateEntity.gateDepth
        )
        
        // Create collision component as a trigger (no physical blocking)
        let collision = CollisionComponent(
            shapes: [shape],
            mode: .trigger,  // Trigger mode - detects collisions without blocking
            filter: .init(
                group: CollisionGroup(rawValue: 1 << 2),  // Gate collision group
                mask: CollisionGroup(rawValue: 1 << 1)    // Collides with fruits
            )
        )
        
        self.components.set(collision)
        
        // Debug visualization - shows gate position
        addDebugVisualization()
    }
    
    // Optional: Visual feedback for debugging
    private func addDebugVisualization() {
        let mesh = MeshResource.generateBox(
            width: MouthGateEntity.gateWidth,
            height: MouthGateEntity.gateHeight,
            depth: MouthGateEntity.gateDepth
        )
        
        var material = UnlitMaterial()
        material.color = .init(tint: .green)
        material.blending = .transparent(opacity: 0.2)  // 80% transparent
        
        let model = ModelComponent(mesh: mesh, materials: [material])
        self.components.set(model)
    }
    
    // Update gate position if needed (for calibration)
    func updateOffset(_ newOffset: SIMD3<Float>) {
        self.position = newOffset
    }
}
