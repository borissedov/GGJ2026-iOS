//
//  GamePhaseChangedEvent.swift
//  HungryGodMask
//

import Foundation

struct GamePhaseChangedEvent: Codable {
    let roomId: UUID
    let oldState: String
    let newState: String
}
