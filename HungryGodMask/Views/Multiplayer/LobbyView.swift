//
//  LobbyView.swift
//  HungryGodMask
//
//  Multiplayer lobby for joining rooms
//

import SwiftUI

struct LobbyView: View {
    @StateObject private var signalRClient = SignalRClient()
    @State private var isReady = false
    @State private var roomId: UUID?
    @State private var playerId: UUID?
    @State private var errorMessage: String?
    @State private var isJoining = false
    
    @ObservedObject var gameManager: GameManager
    @Binding var joinCode: String
    @Binding var playerName: String
    @Binding var navigateToAR: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Oh My Hungry God")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("Multiplayer")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Join Code Display
                VStack(spacing: 20) {
                    // Show player name and join code
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.9))
                            Text(playerName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "door.left.hand.open")
                                .foregroundColor(.white.opacity(0.9))
                            Text("Room: \(joinCode)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    if roomId == nil {
                        // Show joining status
                        if isJoining {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Joining room...")
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button(action: {
                                errorMessage = nil
                                joinRoom()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                    }
                }
                
                // Ready Toggle
                if roomId != nil {
                    VStack(spacing: 20) {
                        Text("✅ Connected to room")
                            .font(.title3)
                            .foregroundColor(.green)
                        
                VStack(spacing: 16) {
                    Toggle(isOn: $isReady) {
                        Text("Ready")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .onChange(of: isReady) { _, newValue in
                        toggleReady(newValue)
                    }
                    
                    if isReady {
                        Text("Waiting for other players...")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 8)
                        
                        Text("Game starts automatically when everyone is ready")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button("Enter AR View") {
                        navigateToAR = true
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 250)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                    }
                }
                
                Spacer()
                
                // Connection status
                VStack(spacing: 8) {
                    HStack {
                        Circle()
                            .fill(signalRClient.isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(signalRClient.connectionState)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                    }
                    
                    if !signalRClient.isConnected {
                        Button(action: {
                            signalRClient.connect()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reconnect")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            signalRClient.connect()
            setupEventHandlers()
            
            // Auto-join room when view appears
            if roomId == nil {
                joinRoom()
            }
        }
    }
    
    private func setupEventHandlers() {
        signalRClient.onStateSnapshot = { snapshot in
            print("📊 Received state snapshot")
            gameManager.handleStateSnapshot(snapshot)
        }
        
        signalRClient.onOrderStarted = { event in
            gameManager.handleOrderStarted(event)
        }
        
        signalRClient.onOrderTotalsUpdated = { event in
            gameManager.handleOrderTotalsUpdated(event)
        }
        
        signalRClient.onError = { error in
            errorMessage = error.message
        }
    }
    
    private func joinRoom() {
        guard !joinCode.isEmpty, roomId == nil else {
            print("⚠️ Cannot join: joinCode=\(joinCode), roomId=\(roomId?.description ?? "nil")")
            return
        }
        
        isJoining = true
        errorMessage = nil
        
        print("📱 JOIN ROOM DEBUG:")
        print("   Join Code: \(joinCode)")
        print("   Connection State: \(signalRClient.connectionState)")
        print("   Is Connected: \(signalRClient.isConnected)")
        
        Task {
            do {
                print("🎮 Attempting to join room with code: \(joinCode)")
                let response = try await signalRClient.joinRoom(joinCode: joinCode.uppercased())
                await MainActor.run {
                    roomId = response.roomId
                    playerId = response.playerId
                    gameManager.enableMultiplayer(signalRClient: signalRClient, roomId: response.roomId)
                    isJoining = false
                    print("✅ Successfully joined room: \(response.roomId)")
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isJoining = false
                    print("❌ Network error: \(error)")
                    print("   Error type: NetworkError.\(error)")
                }
            } catch {
                await MainActor.run {
                    let errorDesc = error.localizedDescription
                    
                    // Log full error details
                    print("❌ JOIN ROOM ERROR DETAILS:")
                    print("   Error: \(error)")
                    print("   Description: \(errorDesc)")
                    print("   Type: \(type(of: error))")
                    if let nsError = error as NSError? {
                        print("   Domain: \(nsError.domain)")
                        print("   Code: \(nsError.code)")
                        print("   UserInfo: \(nsError.userInfo)")
                    }
                    
                    // Provide more user-friendly error messages
                    if errorDesc.contains("error 3") || errorDesc.contains("SignalRError") {
                        errorMessage = "Connection error. Please ensure you're connected to the internet and try again."
                    } else if errorDesc.contains("room not found") || errorDesc.contains("invalid") || errorDesc.lowercased().contains("notfound") {
                        errorMessage = "Room not found. Please check the code on screen and try again."
                    } else {
                        errorMessage = "Failed to join: \(errorDesc)"
                    }
                    isJoining = false
                }
            }
        }
    }
    
    private func toggleReady(_ ready: Bool) {
        guard let roomId = roomId else { return }
        
        Task {
            do {
                try await signalRClient.setReady(roomId: roomId, ready: ready)
            } catch {
                print("❌ Failed to set ready: \(error)")
            }
        }
    }
}
