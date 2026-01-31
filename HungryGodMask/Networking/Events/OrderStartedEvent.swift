//
//  OrderStartedEvent.swift
//  HungryGodMask
//

import Foundation

struct OrderStartedEvent: Codable {
    let orderId: UUID
    let orderNumber: Int
    let required: [String: Int]  // FruitType: count
    let endsAt: Date
    let durationSeconds: Int
}
