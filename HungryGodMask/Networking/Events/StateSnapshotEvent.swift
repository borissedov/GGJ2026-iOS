//
//  StateSnapshotEvent.swift
//  HungryGodMask
//

import Foundation

struct StateSnapshotEvent: Codable {
    let roomId: UUID
    let state: String  // RoomState
    let mood: Int      // GodMood
    let currentOrder: NetworkOrder?
    let orderIndex: Int
    let orderEndsAt: Date?
    let players: [NetworkPlayer]
}
