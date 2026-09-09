//
//  ActivityLevel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Foundation

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case highlyActive = "Highly Active"

    var id: String {
        rawValue
    }

    var subtitle: String {
        switch self {
        case .sedentary:
            return "Little or no exercise, desk job"
        case .lightlyActive:
            return "Light exercise 1-3 days/week"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days/week"
        case .highlyActive:
            return "Hard exercise 6-7 days/week"
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
}
