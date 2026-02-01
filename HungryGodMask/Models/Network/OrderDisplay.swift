//
//  OrderDisplay.swift
//  HungryGodMask
//

import Foundation

struct OrderDisplay {
    let orderNumber: Int
    let required: [FruitType: Int]
    var submitted: [FruitType: Int]  // Changed to var so it can be updated
    var timeRemaining: Int
    
    init(from event: OrderStartedEvent) {
        self.orderNumber = event.orderNumber
        self.timeRemaining = event.durationSeconds
        
        // Convert string keys to FruitType
        var requiredDict: [FruitType: Int] = [:]
        for (key, value) in event.required {
            if let fruitType = FruitType(rawValue: key.lowercased()) {
                requiredDict[fruitType] = value
            }
        }
        self.required = requiredDict
        
        // Initialize submitted with zeros
        var submittedDict: [FruitType: Int] = [:]
        for fruitType in FruitType.allCases {
            submittedDict[fruitType] = 0
        }
        self.submitted = submittedDict
    }
    
    mutating func updateSubmitted(_ event: OrderTotalsUpdatedEvent) {
        var submittedDict: [FruitType: Int] = [:]
        for (key, value) in event.submitted {
            if let fruitType = FruitType(rawValue: key.lowercased()) {
                submittedDict[fruitType] = value
            }
        }
        // Keep zeros for fruit types not in the update
        for fruitType in FruitType.allCases {
            if submittedDict[fruitType] == nil {
                submittedDict[fruitType] = 0
            }
        }
        // Actually update the submitted counts!
        self.submitted = submittedDict
    }
}
