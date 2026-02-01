//
//  WelcomeView.swift
//  HungryGodMask
//
//  Welcome screen with options to start game
//

import SwiftUI

struct WelcomeView: View {
    @Binding var navigateToQRScanner: Bool
    @Binding var navigateToAbout: Bool
    @State private var showHowToPlay = false
    @State private var showShareSheet = false
    
    private let hostURL = "https://ggj2026.borissedov.com"
    
    var body: some View {
        ZStack {
            // Background image
            Image("BackgroundWelcome")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo (if available, otherwise show title)
                if UIImage(named: "Logo") != nil {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500)
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                } else {
                    // Fallback title if logo not available
                    VStack(spacing: 10) {
                        Text("OH MY")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("HUNGRY GOD")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                
                Spacer()
                
                // How To Play expandable section
                VStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            showHowToPlay.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("How To Play")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: showHowToPlay ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .frame(maxWidth: 320)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if showHowToPlay {
                        VStack(alignment: .leading, spacing: 12) {
                            HowToPlayRow(icon: "tv", text: "Open host screen on TV/projector")
                            HowToPlayRow(icon: "qrcode.viewfinder", text: "Scan QR code shown on screen")
                            HowToPlayRow(icon: "person.text.rectangle", text: "Enter your player name")
                            HowToPlayRow(icon: "camera.viewfinder", text: "Point phone at mask on TV until tracked")
                            HowToPlayRow(icon: "checkmark.circle", text: "Mark ready and wait for countdown")
                            HowToPlayRow(icon: "hand.point.up", text: "Swipe fruits to throw at mouth")
                            HowToPlayRow(icon: "target", text: "Match orders exactly - no over-throwing!")
                            HowToPlayRow(icon: "clock", text: "10 seconds per order, 10 orders total")
                            HowToPlayRow(icon: "person.3", text: "Collaborate with your team")
                        }
                        .padding()
                        .frame(maxWidth: 320)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 40)
                
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
                
                // Open on TV button
                Button(action: {
                    showShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "tv")
                            .font(.title3)
                        Text("Open on TV / Projector")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [URL(string: hostURL)!])
                }
                
                Spacer()
                
                // About and Instructions
                HStack(spacing: 20) {
                    Button(action: {
                        navigateToAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("About")
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .font(.footnote)
                    }
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Point camera at the mask on screen")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 30)
            }
        }
    }
}

// Helper view for How To Play rows
struct HowToPlayRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            Text(text)
                .foregroundColor(.white)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
    }
}

// Share sheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
