//
//  GameOverEvent.swift
//  HungryGodMask
//

import Foundation

struct GameOverEvent: Codable {
    let roomId: UUID
    let reason: String
    let completedOrders: Int
    let successCount: Int
    let failCount: Int
}
