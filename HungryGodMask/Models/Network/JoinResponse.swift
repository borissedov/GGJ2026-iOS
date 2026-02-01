//
//  JoinResponse.swift
//  HungryGodMask
//

import Foundation

struct JoinResponse: Codable {
    let roomId: UUID
    let playerId: UUID
    let name: String
}
