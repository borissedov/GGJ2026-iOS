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
    @Binding var restartToQRScanner: Bool
    @State private var showInstructions = true
    
    var body: some View {
        ZStack {
            // AR View
            ARImageTrackingView(gameManager: gameManager)
                .edgesIgnoringSafeArea(.all)
            
            // Screen frame overlay (leaves border)
            if UIImage(named: "ScreenFrame") != nil {
                Image("ScreenFrame")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false) // Allow touches to pass through
            }
            
            // UI Overlay
            VStack {
                // Order display
                if let order = gameManager.currentOrder {
                    OrderOverlayView(order: order)
                        .padding()
                        .id(order.submitted.values.reduce(0, +)) // Force re-render when totals change
                }
                
                Spacer()
                
                // Game over overlay
                if gameManager.isGameOver {
                    VStack(spacing: 20) {
                        Text("🏁 Game Over!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let results = gameManager.gameResults {
                            Text(results)
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            gameManager.restartGame()
                            // Navigate back to QR scanner
                            restartToQRScanner = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.85))
                    )
                    .padding()
                }
                
                // Tracking status indicator (only show before first detection)
                if !gameManager.hasDetectedImage && !gameManager.isGameOver {
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
                if showInstructions && !gameManager.isGameOver {
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
    ContentView(restartToQRScanner: .constant(false))
        .environmentObject(GameManager())
}
