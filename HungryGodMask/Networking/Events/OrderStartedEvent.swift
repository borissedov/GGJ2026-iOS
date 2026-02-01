//
//  OrderStartedEvent.swift
//  HungryGodMask
//

import Foundation

struct OrderStartedEvent: Codable {
    let orderId: UUID
    let orderNumber: Int
    let required: [String: Int]  // FruitType: count
    let endsAt: String  // ISO 8601 date string from server
    let durationSeconds: Int
    
    var endsAtDate: Date? {
        ISO8601DateFormatter().date(from: endsAt)
    }
}
