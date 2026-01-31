//
//  OrderOverlayView.swift
//  HungryGodMask
//
//  Displays current order during multiplayer game
//

import SwiftUI

struct OrderOverlayView: View {
    let order: OrderDisplay
    
    var body: some View {
        VStack(spacing: 8) {
            // Order number
            Text("Order \(order.orderNumber)/10")
                .font(.headline)
                .foregroundColor(.white)
            
            // Fruit requirements
            HStack(spacing: 16) {
                ForEach(FruitType.allCases, id: \.self) { fruit in
                    if let required = order.required[fruit], required > 0 {
                        VStack {
                            Text(fruit.emoji)
                                .font(.system(size: 32))
                            
                            Text("\(order.submitted[fruit] ?? 0)/\(required)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    (order.submitted[fruit] ?? 0) >= required ? .green : .white
                                )
                        }
                    }
                }
            }
            
            // Timer
            ProgressView(value: Double(order.timeRemaining), total: 10.0)
                .tint(.orange)
                .frame(height: 8)
            
            Text("\(order.timeRemaining)s remaining")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
    }
}

extension FruitType {
    var emoji: String {
        switch self {
        case .banana:
            return "🍌"
        case .peach:
            return "🍑"
        case .coconut:
            return "🥥"
        case .watermelon:
            return "🍉"
        }
    }
}
