//
//  NavigationCoordinator.swift
//  HungryGodMask
//
//  Manages app navigation flow
//

import SwiftUI

enum AppScreen {
    case videoSplash
    case welcome
    case qrScanner
    case playerName
    case lobby
    case arGame
}

struct NavigationCoordinator: View {
    @StateObject private var gameManager = GameManager()
    
    @State private var currentScreen: AppScreen = .videoSplash
    @State private var videoSplashComplete = false
    
    // Navigation state
    @State private var navigateToQRScanner = false
    @State private var navigateToSinglePlayer = false
    @State private var navigateToPlayerName = false
    @State private var navigateToLobby = false
    @State private var navigateToARGame = false
    
    // Data state
    @State private var scannedCode: String?
    @State private var manualCode = ""
    @State private var playerName = ""
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .videoSplash:
                VideoSplashView(isComplete: $videoSplashComplete)
                    .onChange(of: videoSplashComplete) { _, complete in
                        if complete {
                            withAnimation {
                                currentScreen = .welcome
                            }
                        }
                    }
                
            case .welcome:
                WelcomeView(
                    navigateToQRScanner: $navigateToQRScanner,
                    navigateToSinglePlayer: $navigateToSinglePlayer
                )
                .onChange(of: navigateToQRScanner) { _, navigate in
                    if navigate {
                        currentScreen = .qrScanner
                    }
                }
                .onChange(of: navigateToSinglePlayer) { _, navigate in
                    if navigate {
                        currentScreen = .arGame
                    }
                }
                
            case .qrScanner:
                QRScannerView(
                    scannedCode: $scannedCode,
                    manualCode: $manualCode,
                    navigateToPlayerName: $navigateToPlayerName
                )
                .onChange(of: navigateToPlayerName) { _, navigate in
                    if navigate {
                        currentScreen = .playerName
                    }
                }
                
            case .playerName:
                PlayerNameView(
                    joinCode: extractJoinCode(from: scannedCode ?? manualCode),
                    playerName: $playerName,
                    navigateToLobby: $navigateToLobby
                )
                .onChange(of: navigateToLobby) { _, navigate in
                    if navigate {
                        currentScreen = .lobby
                    }
                }
                
            case .lobby:
                LobbyView(
                    gameManager: gameManager,
                    joinCode: Binding(
                        get: { 
                            // Extract just the code from scanned/manual input
                            let code = scannedCode ?? manualCode
                            return extractJoinCode(from: code)
                        },
                        set: { _ in }
                    ),
                    playerName: $playerName,
                    navigateToAR: $navigateToARGame
                )
                .environmentObject(gameManager)
                .onChange(of: navigateToARGame) { _, navigate in
                    if navigate {
                        currentScreen = .arGame
                    }
                }
                
            case .arGame:
                ContentView()
                    .environmentObject(gameManager)
            }
        }
        .transition(.opacity)
    }
    
    // Helper to extract join code from URL or raw string
    private func extractJoinCode(from input: String) -> String {
        // If it's a deep link URL (e.g., hungrygod://join/XL3JNE)
        if let url = URL(string: input),
           let scheme = url.scheme,
           scheme.lowercased() == "hungrygod" {
            
            // Check if host is "join" or path contains "join"
            if url.host == "join" || url.pathComponents.contains("join") {
                // Extract the code from the path
                let pathComponents = url.pathComponents.filter { $0 != "/" && $0.lowercased() != "join" }
                if let code = pathComponents.first {
                    print("🔍 Extracted join code '\(code)' from URL: \(input)")
                    return code.uppercased()
                }
            }
        }
        
        // If it's a direct code, just return it uppercased
        print("🔍 Using join code as-is: \(input.uppercased())")
        return input.uppercased()
    }
}
