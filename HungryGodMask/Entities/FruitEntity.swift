//
//  FruitEntity.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import RealityKit
import UIKit
import Combine

class FruitEntity: Entity {
    let fruitType: FruitType
    private var billboardUpdateSubscription: Combine.Cancellable?
    private(set) var isExpanded: Bool = false
    private(set) var isBeingDragged: Bool = false
    
    required init(fruitType: FruitType) {
        self.fruitType = fruitType
        super.init()
        
        setupModel(size: fruitType.thumbnailSize)
        setupPhysics()
        setupCollision(size: fruitType.thumbnailSize)
    }
    
    required init() {
        fatalError("Use init(fruitType:) instead")
    }
    
    private func setupModel(size: Float) {
        // Use a vertical plane for the 2D sprite
        let mesh = MeshResource.generatePlane(width: size, height: size)
        
        print("🍎 DEBUG: Creating \(fruitType.rawValue) sprite, size: \(size)")
        
        var material = UnlitMaterial()
        
        // Try to load the fruit texture from assets
        if let texture = try? TextureResource.load(named: fruitType.assetName) {
            material.color = .init(texture: .init(texture))
            material.blending = .transparent(opacity: 1.0)
            print("🍎 DEBUG: Loaded texture for \(fruitType.rawValue)")
        } else {
            // Fallback to semi-transparent colored material
            let fallbackColor: UIColor = {
                switch fruitType {
                case .banana: return .yellow.withAlphaComponent(0.3)
                case .peach: return .orange.withAlphaComponent(0.3)
                case .coconut: return .brown.withAlphaComponent(0.3)
                case .watermelon: return .green.withAlphaComponent(0.3)
                }
            }()
            material.color = .init(tint: fallbackColor)
            material.blending = .transparent(opacity: 0.3)
            print("🍎 DEBUG: Using fallback color for \(fruitType.rawValue)")
        }
        
        self.components.set(ModelComponent(mesh: mesh, materials: [material]))
        
        print("🍎 DEBUG: Created \(fruitType.rawValue) at size \(size)")
    }
    
    private func setupPhysics() {
        // Start as kinematic (no gravity) until thrown
        let physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: fruitType.mass),
            mode: .kinematic
        )
        self.components.set(physicsBody)
    }
    
    private func setupCollision(size: Float) {
        let shape = ShapeResource.generateSphere(radius: size / 2)
        
        let collision = CollisionComponent(
            shapes: [shape],
            mode: .default,
            filter: .init(
                group: CollisionGroup(rawValue: fruitType.collisionCategory),
                mask: CollisionGroup(rawValue: fruitType.collisionMask)
            )
        )
        self.components.set(collision)
    }
    
    // Called when user starts dragging this fruit
    func startDragging() {
        isBeingDragged = true
    }
    
    // Expand to full size and throw
    func expandAndThrow(velocity: SIMD3<Float>) {
        guard !isExpanded else { return }
        
        isExpanded = true
        isBeingDragged = false
        
        // Update model to full size
        setupModel(size: fruitType.size)
        setupCollision(size: fruitType.size)
        
        print("🍎 DEBUG: Expanded \(fruitType.rawValue) to full size \(fruitType.size)")
        
        // Switch to dynamic physics and apply velocity
        let physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: fruitType.mass),
            mode: .dynamic
        )
        self.components.set(physicsBody)
        
        let motion = PhysicsMotionComponent(
            linearVelocity: velocity,
            angularVelocity: SIMD3<Float>(
                Float.random(in: -2...2),
                Float.random(in: -2...2),
                Float.random(in: -2...2)
            )
        )
        self.components.set(motion)
    }
    
    // Reset fruit to initial state (thumbnail size, kinematic, no motion)
    func resetToThumbnail() {
        isExpanded = false
        isBeingDragged = false
        
        // Reset to thumbnail size
        setupModel(size: fruitType.thumbnailSize)
        setupCollision(size: fruitType.thumbnailSize)
        
        // Reset physics
        let physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: fruitType.mass),
            mode: .kinematic
        )
        self.components.set(physicsBody)
        
        // Remove any existing motion
        self.components.remove(PhysicsMotionComponent.self)
    }
    
    // Legacy method - now uses expandAndThrow internally
    func applyThrowImpulse(_ velocity: SIMD3<Float>) {
        expandAndThrow(velocity: velocity)
    }
    
    // Legacy method - now uses resetToThumbnail internally
    func resetPhysics() {
        resetToThumbnail()
    }
    
    // Billboard effect - make sprite always face camera
    func updateBillboard(cameraTransform: Transform) {
        let cameraPosition = cameraTransform.translation
        let fruitWorldPosition = self.position(relativeTo: nil)
        
        // Orient plane to face camera (plane's +Z should point toward camera)
        // look(at:) points -Z toward target, so we look AWAY from camera
        let awayFromCamera = fruitWorldPosition + (fruitWorldPosition - cameraPosition)
        self.look(at: awayFromCamera, from: fruitWorldPosition, relativeTo: nil)
    }
}
