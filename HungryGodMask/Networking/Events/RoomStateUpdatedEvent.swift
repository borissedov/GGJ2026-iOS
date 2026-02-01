//
//  RoomStateUpdatedEvent.swift
//  HungryGodMask
//

import Foundation

struct RoomStateUpdatedEvent: Codable {
    let roomId: UUID
    let stateValue: Int
    let players: [NetworkPlayer]
    let connectedCount: Int
    let readyCount: Int
    
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
    
    enum CodingKeys: String, CodingKey {
        case roomId, players, connectedCount, readyCount
        case stateValue = "state"
    }
}
