//
//  ThrowGestureHandler.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import UIKit
import RealityKit
import ARKit

class ThrowGestureHandler {
    private weak var arView: ARView?
    private weak var fruitSpawner: FruitSpawner?
    
    private var panGesture: UIPanGestureRecognizer?
    private var selectedFruit: FruitEntity?
    private var gestureStartTime: Date?
    private var lastVelocity: CGPoint = .zero
    
    // Throw parameters
    private let velocityMultiplier: Float = 0.003  // Scale down touch velocity
    private let maxThrowVelocity: Float = 10.0     // Max 10 m/s
    
    init(arView: ARView, fruitSpawner: FruitSpawner) {
        self.arView = arView
        self.fruitSpawner = fruitSpawner
        setupGesture()
    }
    
    private func setupGesture() {
        guard let arView = arView else { return }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(pan)
        panGesture = pan
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = gesture.location(in: arView)
        
        switch gesture.state {
        case .began:
            handleGestureBegan(at: location)
            
        case .changed:
            handleGestureChanged(gesture)
            
        case .ended:
            handleGestureEnded(gesture)
            
        case .cancelled, .failed:
            // Reset fruit if drag was cancelled
            if let fruit = selectedFruit {
                fruit.resetToThumbnail()
            }
            selectedFruit = nil
            gestureStartTime = nil
            
        default:
            break
        }
    }
    
    private func handleGestureBegan(at location: CGPoint) {
        guard let arView = arView else { return }
        
        // Raycast from touch point to find fruit
        let results = arView.hitTest(location)
        
        for result in results {
            if let fruit = result.entity as? FruitEntity {
                selectFruit(fruit)
                return
            }
            
            // Check parent entities
            var parent = result.entity.parent
            while parent != nil {
                if let fruit = parent as? FruitEntity {
                    selectFruit(fruit)
                    return
                }
                parent = parent?.parent
            }
        }
        
        // Fallback: use raycast to world and find nearest fruit
        if let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
            let worldPosition = raycastResult.worldTransform.columns.3
            let position = SIMD3<Float>(worldPosition.x, worldPosition.y, worldPosition.z)
            
            if let fruit = fruitSpawner?.getFruitAt(worldPosition: position) {
                selectFruit(fruit)
            }
        }
    }
    
    private func selectFruit(_ fruit: FruitEntity) {
        selectedFruit = fruit
        gestureStartTime = Date()
        fruit.startDragging()
        
        // Play touch sound
        SoundManager.shared.playTouch()
        
        print("🍎 DEBUG: Started dragging \(fruit.fruitType.rawValue)")
    }
    
    private func handleGestureChanged(_ gesture: UIPanGestureRecognizer) {
        guard let arView = arView,
              let fruit = selectedFruit,
              let camera = arView.session.currentFrame?.camera else { return }
        
        // Track velocity for throw
        lastVelocity = gesture.velocity(in: arView)
        
        // Move fruit to follow finger
        let location = gesture.location(in: arView)
        
        // Get camera vectors
        let cameraTransform = camera.transform
        let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let cameraForward = -SIMD3<Float>(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
        let cameraRight = SIMD3<Float>(cameraTransform.columns.0.x, cameraTransform.columns.0.y, cameraTransform.columns.0.z)
        let cameraUp = SIMD3<Float>(cameraTransform.columns.1.x, cameraTransform.columns.1.y, cameraTransform.columns.1.z)
        
        // Convert screen position to normalized coordinates (-1 to 1)
        let viewSize = arView.bounds.size
        let normalizedX = Float((location.x / viewSize.width) * 2 - 1)
        let normalizedY = Float((location.y / viewSize.height) * 2 - 1)
        
        // Position fruit at finger location in 3D space
        // In portrait mode on iOS:
        // - cameraUp = screen horizontal (left/right)
        // - cameraRight = screen vertical (positive = down)
        let forwardOffset = cameraForward * 0.25
        let horizontalOffset = cameraUp * normalizedX * 0.15      // Screen X → cameraUp
        let verticalOffset = cameraRight * normalizedY * 0.15     // Screen Y → cameraRight
        let worldPosition = cameraPosition + forwardOffset + horizontalOffset + verticalOffset
        
        fruit.setPosition(worldPosition, relativeTo: nil)
    }
    
    private func handleGestureEnded(_ gesture: UIPanGestureRecognizer) {
        guard let fruit = selectedFruit,
              let arView = arView else {
            selectedFruit = nil
            return
        }
        
        // Calculate throw velocity from gesture
        let velocity = gesture.velocity(in: arView)
        
        // Convert 2D screen velocity to 3D world velocity
        let throwVelocity = calculateThrowVelocity(
            screenVelocity: velocity,
            arView: arView
        )
        
        // Expand fruit to full size and apply throw
        fruit.expandAndThrow(velocity: throwVelocity)
        
        // Play throw sound
        SoundManager.shared.playThrow()
        
        print("🍎 DEBUG: Threw \(fruit.fruitType.rawValue) with velocity \(throwVelocity)")
        
        // Clear selection
        selectedFruit = nil
        gestureStartTime = nil
    }
    
    private func calculateThrowVelocity(screenVelocity: CGPoint, arView: ARView) -> SIMD3<Float> {
        guard let camera = arView.session.currentFrame?.camera else {
            return SIMD3<Float>(0, 0, -5)  // Default forward throw
        }
        
        // Get camera transform
        let cameraTransform = camera.transform
        
        // Camera forward, right, and up vectors
        let forward = -SIMD3<Float>(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
        let right = SIMD3<Float>(cameraTransform.columns.0.x, cameraTransform.columns.0.y, cameraTransform.columns.0.z)
        let up = SIMD3<Float>(cameraTransform.columns.1.x, cameraTransform.columns.1.y, cameraTransform.columns.1.z)
        
        // Convert screen velocity to world velocity
        // In portrait mode: screen X → cameraUp, screen Y → cameraRight
        let horizontalVelocity = up * Float(screenVelocity.x) * velocityMultiplier
        let verticalVelocity = right * Float(screenVelocity.y) * velocityMultiplier
        
        // Add forward component for throwing towards screen
        let forwardVelocity = forward * 3.0  // Base forward velocity
        
        var totalVelocity = horizontalVelocity + verticalVelocity + forwardVelocity
        
        // Clamp velocity
        let speed = simd_length(totalVelocity)
        if speed > maxThrowVelocity {
            totalVelocity = normalize(totalVelocity) * maxThrowVelocity
        }
        
        return totalVelocity
    }
    
    func cleanup() {
        if let gesture = panGesture, let arView = arView {
            arView.removeGestureRecognizer(gesture)
        }
        panGesture = nil
        selectedFruit = nil
    }
}
