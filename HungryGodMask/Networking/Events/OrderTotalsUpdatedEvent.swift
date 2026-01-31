//
//  OrderTotalsUpdatedEvent.swift
//  HungryGodMask
//

import Foundation

struct OrderTotalsUpdatedEvent: Codable {
    let orderId: UUID
    let submitted: [String: Int]  // FruitType: count
    let timestamp: Date
}
