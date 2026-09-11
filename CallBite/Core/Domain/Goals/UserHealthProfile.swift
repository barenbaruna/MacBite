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
    var targetWeightKg: Double?
    var goalCategory: GoalCategory?

    init(
        age: Int,
        biologicalSex: BiologicalSex,
        weightKg: Double,
        heightCm: Double,
        targetWeightKg: Double? = nil,
        goalCategory: GoalCategory? = nil
    ) {
        self.age = age
        self.biologicalSex = biologicalSex
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.targetWeightKg = targetWeightKg
        self.goalCategory = goalCategory
    }

    static let empty = UserHealthProfile(
        age: 0,
        biologicalSex: .preferNotToSay,
        weightKg: 0,
        heightCm: 0
    )
}
