//
//  MouthGateEntity.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import RealityKit
import UIKit

class MouthGateEntity: Entity {
    
    // Offset from image anchor to mouth position (adjust based on your mask)
    static let defaultMouthOffset = SIMD3<Float>(0, 0, 0.12)  // 12cm down from center (positive Z)
    
    // Gate dimensions (slightly oversized to account for animation drift)
    static let gateWidth: Float = 0.15   // 15cm wide (screen horizontal)
    static let gateHeight: Float = 0.10  // 10cm depth (toward camera)
    static let gateDepth: Float = 0.10   // 10cm tall (screen vertical, 2x original)
    
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
