//
//  GoalCategory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Nutritional weight goal categories.
enum GoalCategory: String, CaseIterable, Identifiable, Codable {
    case cutting = "Lose Weight"
    case maintaining = "Maintain Weight"
    case bulking = "Gain Weight"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .cutting: return "arrow.down.right"
        case .maintaining: return "equal"
        case .bulking: return "arrow.up.right"
        }
    }
}
