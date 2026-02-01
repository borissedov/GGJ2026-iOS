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
    var orderEndsAt: String?  // ISO 8601 date string
    var players: [NetworkPlayer]
    
    var orderEndsAtDate: Date? {
        guard let orderEndsAt = orderEndsAt else { return nil }
        return ISO8601DateFormatter().date(from: orderEndsAt)
    }
    
    init(from snapshot: StateSnapshotEvent) {
        self.roomId = snapshot.roomId
        self.state = snapshot.state  // Now uses computed property
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
    let startsAt: String  // ISO 8601 date string from server
    let endsAt: String    // ISO 8601 date string from server
    let status: Int       // OrderStatus enum value
    
    var startsAtDate: Date? {
        ISO8601DateFormatter().date(from: startsAt)
    }
    
    var endsAtDate: Date? {
        ISO8601DateFormatter().date(from: endsAt)
    }
}
