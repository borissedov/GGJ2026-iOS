//
//  OrderResolvedEvent.swift
//  HungryGodMask
//

import Foundation

struct OrderResolvedEvent: Codable {
    let orderId: UUID
    let result: String  // OrderStatus
    let required: [String: Int]
    let submitted: [String: Int]
    let newMood: Int
}
