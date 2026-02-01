//
//  ARImageTrackingView.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARImageTrackingView: UIViewRepresentable {
    @ObservedObject var gameManager: GameManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session for world tracking (provides camera pose)
        let configuration = ARWorldTrackingConfiguration()
        
        // Load reference images from asset catalog
        if let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Resources",
            bundle: nil
        ) {
            configuration.detectionImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        // Enable auto-focus for better tracking
        configuration.isAutoFocusEnabled = true
        
        // Start AR session
        arView.session.run(configuration)
        
        // Setup coordinator
        context.coordinator.setup(arView: arView)
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gameManager: gameManager)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var gameManager: GameManager
        var arView: ARView?
        var imageAnchor: AnchorEntity?
        var mouthGate: MouthGateEntity?
        var fruitSpawner: FruitSpawner?
        var gestureHandler: ThrowGestureHandler?
        var updateSubscription: Combine.Cancellable?
        var lastTrackedTransform: simd_float4x4?  // Store last known position
        
        init(gameManager: GameManager) {
            self.gameManager = gameManager
            super.init()
        }
        
        func setup(arView: ARView) {
            self.arView = arView
            
            // Setup collision detection
            gameManager.setupCollisionDetection(for: arView.scene)
            
            // Setup update loop for billboarding
            setupUpdateLoop()
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let imageAnchor = anchor as? ARImageAnchor else { continue }
                
                // Image detected - setup AR content
                handleImageDetected(imageAnchor: imageAnchor)
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    // Only update position when actively tracked
                    if imageAnchor.isTracked {
                        // Store the current transform
                        lastTrackedTransform = imageAnchor.transform
                        
                        // Manually update the world anchor to match the image position
                        if let anchorEntity = self.imageAnchor {
                            anchorEntity.transform = Transform(matrix: imageAnchor.transform)
                        }
                        
                        // Update tracking state
                        DispatchQueue.main.async { [weak self] in
                            self?.gameManager.isTracking = true
                        }
                    } else {
                        // Not tracked - keep anchor at last known position, just update state
                        print("🍎 DEBUG: Tracking lost, keeping gate at last position")
                        DispatchQueue.main.async { [weak self] in
                            self?.gameManager.isTracking = false
                        }
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            for anchor in anchors {
                if anchor is ARImageAnchor {
                    // ARKit removed the image anchor, but we keep our world anchor in place
                    // Just update tracking state - the collision box stays at last known position
                    DispatchQueue.main.async { [weak self] in
                        self?.gameManager.isTracking = false
                    }
                    print("🍎 DEBUG: Image anchor removed by ARKit, but gate remains at last position")
                }
            }
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            guard let arView = arView else { return }
            
            let configuration = ARWorldTrackingConfiguration()
            if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
                configuration.detectionImages = referenceImages
                configuration.maximumNumberOfTrackedImages = 1
            }
            configuration.isAutoFocusEnabled = true
            arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        
        private func handleImageDetected(imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }
            
            // Only setup once
            guard self.imageAnchor == nil else {
                // Already set up - we'll update position in didUpdate
                return
            }
            
            print("🍎 DEBUG: Image detected, setting up AR content")
            print("🍎 DEBUG: Image transform: \(imageAnchor.transform)")
            
            // Store initial transform
            lastTrackedTransform = imageAnchor.transform
            
            // Create world-anchored entity at ORIGIN (not at the image position)
            // We'll use the .transform property to position it at the image location
            // This allows it to persist even when ARKit removes the image anchor
            let anchorEntity = AnchorEntity(world: .zero)
            anchorEntity.transform = Transform(matrix: imageAnchor.transform)
            arView.scene.addAnchor(anchorEntity)
            self.imageAnchor = anchorEntity
            
            // Create invisible mouth gate
            let gate = MouthGateEntity()
            anchorEntity.addChild(gate)
            self.mouthGate = gate
            
            print("🍎 DEBUG: Mouth gate created at position: \(anchorEntity.transform.translation)")
            
            // Update tracking state
            DispatchQueue.main.async { [weak self] in
                self?.gameManager.isTracking = true
                self?.gameManager.hasDetectedImage = true  // Mark as detected (stays true forever)
            }
            
            // Delay fruit spawning until camera is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self, let arView = self.arView else { return }
                
                print("🍎 DEBUG: Initializing fruit spawner...")
                
                // Setup fruit spawner with SCENE
                let spawner = FruitSpawner()
                spawner.setup(in: arView.scene)
                self.fruitSpawner = spawner
                
                // Setup gesture handler
                let handler = ThrowGestureHandler(arView: arView, fruitSpawner: spawner)
                self.gestureHandler = handler
                
                print("🍎 DEBUG: Fruit spawner setup complete")
            }
        }
        
        private func setupUpdateLoop() {
            guard let arView = arView else { return }
            
            // Subscribe to scene updates for billboarding
            updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.updateFrame()
            }
        }
        
        private func updateFrame() {
            guard let arView = arView,
                  let currentFrame = arView.session.currentFrame else { return }
            
            let cameraTransform = Transform(matrix: currentFrame.camera.transform)
            
            // Add debug logging (only log occasionally to avoid spam)
            if Int.random(in: 0..<60) == 0 {  // Log ~1 per second at 60fps
                print("🍎 DEBUG: Camera at: \(cameraTransform.translation)")
            }
            
            // Update fruit positions and billboarding
            fruitSpawner?.updateFruitPositions(cameraTransform: cameraTransform)
        }
        
        deinit {
            updateSubscription?.cancel()
            gestureHandler?.cleanup()
        }
    }
}
