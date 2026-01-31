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
    @Published var currentRoomId: UUID?
    @Published var currentPlayerId: UUID?
    
    private let hubUrl: String
    private var hubConnection: HubConnection?
    
    // Event handlers
    var onStateSnapshot: ((StateSnapshotEvent) -> Void)?
    var onGamePhaseChanged: ((GamePhaseChangedEvent) -> Void)?
    var onOrderStarted: ((OrderStartedEvent) -> Void)?
    var onOrderTotalsUpdated: ((OrderTotalsUpdatedEvent) -> Void)?
    var onOrderResolved: ((OrderResolvedEvent) -> Void)?
    var onError: ((ErrorEvent) -> Void)?
    
    init(hubUrl: String = "https://ohmyhungrygod-backend-f5che7gshshzhzhm.southafricanorth-01.azurewebsites.net/gamehub") {
        self.hubUrl = hubUrl
    }
    
    func connect() {
        hubConnection = HubConnectionBuilder(url: URL(string: hubUrl)!)
            .withLogging(minLogLevel: .info)
            .withAutoReconnect()
            .build()
        
        setupEventHandlers()
        
        hubConnection?.start()
    }
    
    func disconnect() {
        hubConnection?.stop()
        isConnected = false
    }
    
    func joinRoom(joinCode: String) async throws -> JoinResponse {
        return try await withCheckedThrowingContinuation { continuation in
            hubConnection?.invoke(method: "JoinRoom", arguments: [joinCode], resultType: JoinResponse.self) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                } else {
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
        
        hubConnection?.on(method: "StateSnapshot") { [weak self] (snapshot: StateSnapshotEvent) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onStateSnapshot?(snapshot)
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
        
        hubConnection?.on(method: "Error") { [weak self] (error: ErrorEvent) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onError?(error)
            }
        }
    }
}

enum NetworkError: Error {
    case notConnected
    case notImplemented
    case invalidResponse
}
