//
//  LobbyView.swift
//  HungryGodMask
//
//  Multiplayer lobby for joining rooms
//

import SwiftUI

struct LobbyView: View {
    @StateObject private var signalRClient = SignalRClient()
    @State private var joinCode = ""
    @State private var isReady = false
    @State private var roomId: UUID?
    @State private var playerId: UUID?
    @State private var errorMessage: String?
    @State private var isJoining = false
    @State private var navigateToAR = false
    
    @ObservedObject var gameManager: GameManager
    
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
                
                // Join Code Input
                VStack(spacing: 20) {
                    TextField("Enter Join Code", text: $joinCode)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .textCase(.uppercase)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .disabled(roomId != nil)
                    
                    if roomId == nil {
                        Button(action: joinRoom) {
                            HStack {
                                if isJoining {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Join Room")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: 200)
                            .padding()
                            .background(joinCode.count >= 6 ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        .disabled(joinCode.count < 6 || isJoining)
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
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
                        
                        Button("Start AR Game") {
                            navigateToAR = true
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 250)
                        .background(isReady ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .disabled(!isReady)
                    }
                }
                
                Spacer()
                
                // Connection status
                HStack {
                    Circle()
                        .fill(signalRClient.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(signalRClient.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .onAppear {
            signalRClient.connect()
            setupEventHandlers()
        }
        .fullScreenCover(isPresented: $navigateToAR) {
            ContentView()
                .environmentObject(gameManager)
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
        guard !joinCode.isEmpty else { return }
        
        isJoining = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await signalRClient.joinRoom(joinCode: joinCode.uppercased())
                await MainActor.run {
                    roomId = response.roomId
                    playerId = response.playerId
                    gameManager.enableMultiplayer(signalRClient: signalRClient, roomId: response.roomId)
                    isJoining = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to join room: \(error.localizedDescription)"
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
