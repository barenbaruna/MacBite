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
    case preferNotToSay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notSet: return "Not Set"
        case .female: return "Female"
        case .male: return "Male"
        case .preferNotToSay: return "Prefer not to say"
        }
    }

    /// Backwards compatibility alias for `.preferNotToSay`.
    static let other: BiologicalSex = .preferNotToSay

    /// Selectable cases for user input forms (excluding .notSet).
    static let selectableCases: [BiologicalSex] = [.female, .male, .preferNotToSay]

    /// Mifflin-St Jeor equation constant for Basal Metabolic Rate (BMR).
    /// - Male: +5
    /// - Female: -161
    /// - Prefer not to say: -78 (Midpoint average between male +5 and female -161: (5 + (-161)) / 2 = -78)
    var bmrConstant: Double {
        switch self {
        case .male:
            return 5.0
        case .female:
            return -161.0
        case .preferNotToSay, .notSet:
            return -78.0
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if raw == "other" || raw == "preferNotToSay" {
            self = .preferNotToSay
        } else if let match = BiologicalSex(rawValue: raw) {
            self = match
        } else {
            self = .notSet
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
