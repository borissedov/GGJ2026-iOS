//
//  SignalRClient.swift
//  HungryGodMask
//
//  Created for multiplayer integration
//

import Foundation
import Combine
import SignalRClient

class SignalRClient: ObservableObject {
    @Published var isConnected = false
    @Published var connectionState: String = "Disconnected"
    @Published var currentRoomId: UUID?
    @Published var currentPlayerId: UUID?
    
    private let hubUrl: String
    private var hubConnection: HubConnection?
    private var connectionDelegate: ConnectionDelegate?
    
    // Event handlers
    var onRoomStateUpdated: ((RoomStateUpdatedEvent) -> Void)?
    var onStateSnapshot: ((StateSnapshotEvent) -> Void)?
    var onGamePhaseChanged: ((GamePhaseChangedEvent) -> Void)?
    var onCountdownStarted: ((CountdownStartedEvent) -> Void)?
    var onOrderStarted: ((OrderStartedEvent) -> Void)?
    var onOrderTotalsUpdated: ((OrderTotalsUpdatedEvent) -> Void)?
    var onOrderResolved: ((OrderResolvedEvent) -> Void)?
    var onGameFinished: ((GameFinishedEvent) -> Void)?
    var onGameOver: ((GameOverEvent) -> Void)?
    var onError: ((ErrorEvent) -> Void)?
    
    init(hubUrl: String = "https://ohmyhungrygod-backend-f5che7gshshzhzhm.southafricanorth-01.azurewebsites.net/gamehub") {
        self.hubUrl = hubUrl
    }
    
    func connect() {
        guard hubConnection == nil else {
            print("⚠️ Already connected or connecting")
            return
        }
        
        print("🔌 Starting SignalR connection to \(hubUrl)")
        
        connectionDelegate = ConnectionDelegate(client: self)
        
        hubConnection = HubConnectionBuilder(url: URL(string: hubUrl)!)
            .withLogging(minLogLevel: .debug)
            .withAutoReconnect()
            .withHubConnectionDelegate(delegate: connectionDelegate!)
            .build()
        
        setupEventHandlers()
        
        hubConnection?.start()
    }
    
    func disconnect() {
        hubConnection?.stop()
        isConnected = false
    }
    
    func joinRoom(joinCode: String, playerName: String) async throws -> JoinResponse {
        // Wait for connection if not connected
        if hubConnection == nil {
            print("❌ Hub connection is nil")
            throw NetworkError.notConnected
        }
        
        print("🔍 JOIN ROOM DEBUG:")
        print("   Hub URL: \(hubUrl)")
        print("   Join Code: '\(joinCode)'")
        print("   Player Name: '\(playerName)'")
        print("   Is Connected: \(isConnected)")
        print("   Connection State: \(connectionState)")
        
        // Wait up to 10 seconds for connection
        let maxWaitTime = 10.0
        let checkInterval = 0.5
        var waitedTime = 0.0
        
        while !isConnected && waitedTime < maxWaitTime {
            try await Task.sleep(nanoseconds: UInt64(checkInterval * 1_000_000_000))
            waitedTime += checkInterval
            print("⏳ Waiting for connection... (\(Int(waitedTime))s)")
        }
        
        guard isConnected else {
            print("❌ Connection timeout after \(waitedTime)s")
            throw NetworkError.notConnected
        }
        
        print("📡 Invoking JoinRoom method on server")
        print("   Arguments: [\"\(joinCode)\", \"\(playerName)\"]")
        
        return try await withCheckedThrowingContinuation { continuation in
            hubConnection?.invoke(method: "JoinRoom", arguments: [joinCode, playerName], resultType: JoinResponse.self) { result, error in
                print("🔍 SERVER RESPONSE:")
                
                if let error = error {
                    print("❌ Error received:")
                    print("   Error: \(error)")
                    print("   LocalizedDescription: \(error.localizedDescription)")
                    
                    if let nsError = error as NSError? {
                        print("   Domain: \(nsError.domain)")
                        print("   Code: \(nsError.code)")
                        print("   UserInfo: \(nsError.userInfo)")
                    }
                    
                    continuation.resume(throwing: error)
                    
                } else if let result = result {
                    print("✅ Success:")
                    print("   Room ID: \(result.roomId)")
                    print("   Player ID: \(result.playerId)")
                    print("   Player Name: \(result.name)")
                    
                    continuation.resume(returning: result)
                    
                } else {
                    print("❌ No result and no error (invalid state)")
                    continuation.resume(throwing: NetworkError.invalidResponse)
                }
            }
        }
    }
    
    func setReady(roomId: UUID, ready: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            hubConnection?.invoke(method: "SetReady", roomId.uuidString, ready) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func reportHit(roomId: UUID, hitId: UUID, fruitType: FruitType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            hubConnection?.invoke(method: "ReportHit", roomId.uuidString, hitId.uuidString, fruitType.rawValue) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func ping(roomId: UUID) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            hubConnection?.invoke(method: "Ping", roomId.uuidString) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func setupEventHandlers() {
        // Register handlers for server events
        
        hubConnection?.on(method: "RoomStateUpdated") { [weak self] (event: RoomStateUpdatedEvent) in
            guard let self = self else { return }
            print("📢 RoomStateUpdated received - State: \(event.state), Players: \(event.connectedCount)")
            DispatchQueue.main.async {
                self.onRoomStateUpdated?(event)
            }
        }
        
        hubConnection?.on(method: "StateSnapshot") { [weak self] (snapshot: StateSnapshotEvent) in
            guard let self = self else { return }
            print("📊 StateSnapshot received - State: \(snapshot.state)")
            DispatchQueue.main.async {
                self.onStateSnapshot?(snapshot)
            }
        }
        
        hubConnection?.on(method: "CountdownStarted") { [weak self] (event: CountdownStartedEvent) in
            guard let self = self else { return }
            print("⏳ CountdownStarted received - game starting soon")
            DispatchQueue.main.async {
                self.onCountdownStarted?(event)
            }
        }
        
        hubConnection?.on(method: "OrderStarted") { [weak self] (event: OrderStartedEvent) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onOrderStarted?(event)
            }
        }
        
        hubConnection?.on(method: "OrderTotalsUpdated") { [weak self] (event: OrderTotalsUpdatedEvent) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onOrderTotalsUpdated?(event)
            }
        }
        
        hubConnection?.on(method: "OrderResolved") { [weak self] (event: OrderResolvedEvent) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onOrderResolved?(event)
            }
        }
        
        hubConnection?.on(method: "GameFinished") { [weak self] (event: GameFinishedEvent) in
            guard let self = self else { return }
            print("🎉 GameFinished received")
            DispatchQueue.main.async {
                self.onGameFinished?(event)
            }
        }
        
        hubConnection?.on(method: "GameOver") { [weak self] (event: GameOverEvent) in
            guard let self = self else { return }
            print("💀 GameOver received")
            DispatchQueue.main.async {
                self.onGameOver?(event)
            }
        }
        
        hubConnection?.on(method: "Error") { [weak self] (error: ErrorEvent) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onError?(error)
            }
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case notConnected
    case notImplemented
    case invalidResponse
    case connectionTimeout
    
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to server. Please check your internet connection."
        case .notImplemented:
            return "Feature not implemented yet."
        case .invalidResponse:
            return "Invalid response from server."
        case .connectionTimeout:
            return "Connection timeout. Please try again."
        }
    }
}

// MARK: - Connection Delegate

class ConnectionDelegate: HubConnectionDelegate {
    weak var client: SignalRClient?
    
    init(client: SignalRClient) {
        self.client = client
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
        DispatchQueue.main.async { [weak self] in
            self?.client?.isConnected = true
            self?.client?.connectionState = "Connected"
            print("✅ SignalR connection opened")
            print("   Connection ID: \(hubConnection.connectionId ?? "unknown")")
        }
    }
    
    func connectionDidFailToOpen(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.client?.isConnected = false
            self?.client?.connectionState = "Failed"
            print("❌ SignalR connection failed to open: \(error)")
        }
    }
    
    func connectionDidClose(error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.client?.isConnected = false
            self?.client?.connectionState = "Disconnected"
            if let error = error {
                print("❌ SignalR connection closed with error: \(error)")
            } else {
                print("🔌 SignalR connection closed")
            }
        }
    }
    
    func connectionWillReconnect(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.client?.isConnected = false
            self?.client?.connectionState = "Reconnecting"
            print("🔄 SignalR reconnecting after error: \(error)")
        }
    }
    
    func connectionDidReconnect() {
        DispatchQueue.main.async { [weak self] in
            self?.client?.isConnected = true
            self?.client?.connectionState = "Connected"
            print("✅ SignalR reconnected")
        }
    }
}
