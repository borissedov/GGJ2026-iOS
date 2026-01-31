//
//  FruitType.swift
//  HungryGodMask
//
//  Created by Boris Sedov on 31/01/2026.
//

import Foundation

enum FruitType: String, CaseIterable {
    case banana
    case peach
    case coconut
    case watermelon
    
    // Thumbnail size for panel display (small icons at bottom of screen)
    var thumbnailSize: Float {
        return 0.04  // 4cm - compact size for panel icons
    }
    
    // Full size when thrown (in meters)
    var size: Float {
        switch self {
        case .banana:
            return 0.12  // 12cm
        case .peach:
            return 0.10  // 10cm
        case .coconut:
            return 0.15  // 15cm
        case .watermelon:
            return 0.25  // 25cm
        }
    }
    
    // Mass in kilograms
    var mass: Float {
        switch self {
        case .banana:
            return 0.15  // Light
        case .peach:
            return 0.2   // Medium
        case .coconut:
            return 0.5   // Heavy
        case .watermelon:
            return 4.0   // Very Heavy
        }
    }
    
    // Asset name in Assets.xcassets
    var assetName: String {
        return rawValue.capitalized
    }
    
    // Collision category bit mask
    var collisionCategory: UInt32 {
        return 1 << 1  // Fruit collision category
    }
    
    // What this entity can collide with
    var collisionMask: UInt32 {
        return (1 << 2)  // Can collide with gate
    }
}
