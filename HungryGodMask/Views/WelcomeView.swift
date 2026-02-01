//
//  WelcomeView.swift
//  HungryGodMask
//
//  Welcome screen with options to start game
//

import SwiftUI

struct WelcomeView: View {
    @Binding var navigateToQRScanner: Bool
    
    var body: some View {
        ZStack {
            // Background image
            Image("BackgroundWelcome")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                VStack(spacing: 10) {
                    Text("OH MY")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("HUNGRY GOD")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                
                Spacer()
                
                // Start game button
                Button(action: {
                    navigateToQRScanner = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.title2)
                        Text("Start Game")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: 280)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Instructions hint
                Text("Point your camera at the mask on screen")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
            }
        }
    }
}
