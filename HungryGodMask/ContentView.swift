//
//  ContentView.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showInstructions = true
    
    var body: some View {
        ZStack {
            // AR View
            ARImageTrackingView(gameManager: gameManager)
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                // Order display
                if let order = gameManager.currentOrder {
                    OrderOverlayView(order: order)
                        .padding()
                }
                
                Spacer()
                
                // Tracking status indicator (only show before first detection)
                if !gameManager.hasDetectedImage {
                    Text("Point camera at the mask on TV/screen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.8))
                        )
                        .padding()
                }
                
                // Instructions (fade after 5 seconds)
                if showInstructions {
                    VStack(spacing: 8) {
                        Text("HOW TO PLAY")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("1. Point camera at mask on TV/screen")
                        Text("2. Swipe fruits to throw them")
                        Text("3. Aim for the mouth to score!")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding()
                    .transition(.opacity)
                    .onAppear {
                        // Hide instructions after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showInstructions = false
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 100)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
}
