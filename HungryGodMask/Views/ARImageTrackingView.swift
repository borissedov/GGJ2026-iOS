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
                    // Check if image is being tracked
                    if imageAnchor.isTracked {
                        // Update tracking state
                        DispatchQueue.main.async { [weak self] in
                            self?.gameManager.isTracking = true
                        }
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            for anchor in anchors {
                if anchor is ARImageAnchor {
                    DispatchQueue.main.async { [weak self] in
                        self?.gameManager.isTracking = false
                    }
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
            guard self.imageAnchor == nil else { return }
            
            print("🍎 DEBUG: Image detected, setting up AR content")
            
            // Create anchor entity at image position (for mask gate)
            let anchorEntity = AnchorEntity(anchor: imageAnchor)
            arView.scene.addAnchor(anchorEntity)
            self.imageAnchor = anchorEntity
            
            // Create invisible mouth gate
            let gate = MouthGateEntity()
            anchorEntity.addChild(gate)
            self.mouthGate = gate
            
            print("🍎 DEBUG: Mouth gate created")
            
            // Update tracking state
            DispatchQueue.main.async { [weak self] in
                self?.gameManager.isTracking = true
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
