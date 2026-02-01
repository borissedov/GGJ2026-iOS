//
//  GameFinishedEvent.swift
//  HungryGodMask
//

import Foundation

struct PlayerStats: Codable {
    let name: String
    let hitCount: Int
    let contributionPercentage: Double
}

struct GameFinishedEvent: Codable {
    let roomId: UUID
    let totalOrders: Int
    let successCount: Int
    let failCount: Int
    let finalMood: Int
    let playerStats: [PlayerStats]
}
