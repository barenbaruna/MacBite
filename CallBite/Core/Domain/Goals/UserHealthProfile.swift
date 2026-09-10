//
//  UserHealthProfile.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// User physical profile and health metrics for nutritional calculations.
struct UserHealthProfile: Equatable, Codable {
    var age: Int
    var biologicalSex: BiologicalSex
    var weightKg: Double
    var heightCm: Double

    static let empty = UserHealthProfile(
        age: 0,
        biologicalSex: .male,
        weightKg: 0,
        heightCm: 0
    )
}
