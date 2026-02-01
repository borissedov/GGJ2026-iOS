//
//  AboutView.swift
//  HungryGodMask
//
//  About screen with GGJ info and credits
//

import SwiftUI

struct AboutView: View {
    @Binding var navigateBack: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.95)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button(action: {
                        navigateBack = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                    
                    Text("About")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible placeholder for centering
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.clear)
                        .padding()
                    }
                    .disabled(true)
                }
                .background(Color.black.opacity(0.5))
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo (if available)
                        if UIImage(named: "Logo") != nil {
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200)
                                .padding(.top, 40)
                        }
                        
                        // Title
                        Text("Oh My Hungry God")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, UIImage(named: "Logo") == nil ? 20 : 0)
                    
                    // Game description
                    Text("A synchronous multiplayer AR game where players work together to feed a hungry god!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal)
                    
                    // GGJ Info
                    VStack(spacing: 15) {
                        Text("Created for Global Game Jam 2026")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("🇲🇺 Mauritius")
                            .font(.title3)
                            .foregroundColor(.green)
                        
                        Text("Institut Français de Maurice")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Link(destination: URL(string: "https://globalgamejam.org/games/2026/oh-my-hungry-god-5")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("View on Global Game Jam")
                            }
                            .padding()
                            .background(Color.purple.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal)
                    
                    // Technologies
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Technologies")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        TechRow(icon: "arkit", text: "ARKit & RealityKit")
                        TechRow(icon: "swift", text: "Swift & SwiftUI")
                        TechRow(icon: "network", text: "SignalR WebSocket")
                        TechRow(icon: "server.rack", text: ".NET 9 Backend")
                        TechRow(icon: "globe", text: "TypeScript Frontend")
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 40)
                    }
                }
            }
        }
    }
}

// Helper view for technology rows
struct TechRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 30)
            Text(text)
                .foregroundColor(.white)
                .font(.body)
        }
    }
}
