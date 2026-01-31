//
//  NetworkGameState.swift
//  HungryGodMask
//

import Foundation

struct NetworkGameState {
    let roomId: UUID
    var state: String
    var mood: Int
    var currentOrder: NetworkOrder?
    var orderIndex: Int
    var orderEndsAt: Date?
    var players: [NetworkPlayer]
    
    init(from snapshot: StateSnapshotEvent) {
        self.roomId = snapshot.roomId
        self.state = snapshot.state
        self.mood = snapshot.mood
        self.currentOrder = snapshot.currentOrder
        self.orderIndex = snapshot.orderIndex
        self.orderEndsAt = snapshot.orderEndsAt
        self.players = snapshot.players
    }
}

struct NetworkPlayer: Codable {
    let playerId: UUID
    let connectionId: String
    let isConnected: Bool
    let isReady: Bool
}

struct NetworkOrder: Codable {
    let orderId: UUID
    let required: [String: Int]  // FruitType: count
    let submitted: [String: Int]
    let startsAt: Date
    let endsAt: Date
    let status: String
}
