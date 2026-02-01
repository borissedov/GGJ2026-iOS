//
//  StateSnapshotEvent.swift
//  HungryGodMask
//

import Foundation

struct StateSnapshotEvent: Codable {
    let roomId: UUID
    let stateValue: Int  // RoomState as integer
    let mood: Int        // GodMood
    let currentOrder: NetworkOrder?
    let orderIndex: Int
    let orderEndsAt: String?  // ISO 8601 date string from server
    let players: [NetworkPlayer]
    
    var state: String {
        // Map integer to RoomState string
        // 0=Welcome, 1=Lobby, 2=Countdown, 3=InGame, 4=GameOver, 5=Results, 6=Closed
        switch stateValue {
        case 0: return "Welcome"
        case 1: return "Lobby"
        case 2: return "Countdown"
        case 3: return "InGame"
        case 4: return "GameOver"
        case 5: return "Results"
        case 6: return "Closed"
        default: return "Unknown"
        }
    }
    
    var orderEndsAtDate: Date? {
        guard let orderEndsAt = orderEndsAt else { return nil }
        return ISO8601DateFormatter().date(from: orderEndsAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case roomId, mood, currentOrder, orderIndex, orderEndsAt, players
        case stateValue = "state"
    }
}
