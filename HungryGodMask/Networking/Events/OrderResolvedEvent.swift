//
//  OrderResolvedEvent.swift
//  HungryGodMask
//

import Foundation

// Matches server's OrderStatus enum
enum OrderStatus: Int, Codable {
    case active = 0
    case successExact = 1
    case failOver = 2
    case failTimeout = 3
}

struct OrderResolvedEvent: Codable {
    let orderId: UUID
    let result: Int  // OrderStatus enum value from server
    let required: [String: Int]
    let submitted: [String: Int]
    let newMood: Int
    
    var orderStatus: OrderStatus? {
        OrderStatus(rawValue: result)
    }
}
