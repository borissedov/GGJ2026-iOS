//
//  CountdownStartedEvent.swift
//  HungryGodMask
//

import Foundation

struct CountdownStartedEvent: Codable {
    let roomId: UUID
    let startsAt: String  // ISO 8601 date string from server
    let durationSeconds: Int
    
    var startsAtDate: Date? {
        ISO8601DateFormatter().date(from: startsAt)
    }
}
