//
//  PlayerNameView.swift
//  HungryGodMask
//
//  Enter player name screen
//

import SwiftUI

struct PlayerNameView: View {
    let joinCode: String
    @Binding var playerName: String
    @Binding var navigateToLobby: Bool
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.purple.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Title
                VStack(spacing: 15) {
                    Text("What's your name?")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Show join code
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Room: \(joinCode)")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // Name input
                VStack(spacing: 20) {
                    TextField("Your Name", text: $playerName)
                        .font(.system(size: 28, weight: .medium))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                        .focused($isTextFieldFocused)
                        .autocorrectionDisabled()
                    
                    Text("This is how others will see you")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    navigateToLobby = true
                }) {
                    HStack {
                        Text("Continue")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: 250)
                    .padding(.vertical, 18)
                    .background(
                        playerName.count >= 2 ? 
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: playerName.count >= 2 ? Color.green.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 5)
                }
                .disabled(playerName.count < 2)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Auto-focus text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
}
