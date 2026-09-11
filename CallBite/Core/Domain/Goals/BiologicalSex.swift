//
//  BiologicalSex.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Biological sex representation aligned with Apple Health (HKBiologicalSex) for BMR calculations.
enum BiologicalSex: String, CaseIterable, Identifiable, Codable {
    case notSet
    case female
    case male
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notSet: return "Not Set"
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Prefer not to say"
        }
    }

    /// Selectable cases for user input forms (excluding .notSet).
    static let selectableCases: [BiologicalSex] = [.female, .male, .other]
}
