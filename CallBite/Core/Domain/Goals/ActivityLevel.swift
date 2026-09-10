//
//  ActivityLevel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Physical activity level multiplier for Total Daily Energy Expenditure (TDEE).
enum ActivityLevel: String, CaseIterable, Identifiable, Codable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case highlyActive = "Highly Active"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .sedentary:
            return "Little or no exercise, mostly desk job"
        case .lightlyActive:
            return "Light exercise 1-3 days/week or casual walks"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days/week"
        case .highlyActive:
            return "Heavy exercise 6-7 days/week"
        }
    }

    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .lightlyActive:
            return 1.375
        case .moderatelyActive:
            return 1.55
        case .highlyActive:
            return 1.725
        }
    }

    var iconName: String {
        switch self {
        case .sedentary:
            return "figure.seated.side.left"
        case .lightlyActive:
            return "figure.walk"
        case .moderatelyActive:
            return "figure.run"
        case .highlyActive:
            return "flame.fill"
        }
    }
}
