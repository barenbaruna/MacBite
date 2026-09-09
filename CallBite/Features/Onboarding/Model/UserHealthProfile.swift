//
//  UserHealthProfile.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Foundation

struct UserHealthProfile: Equatable {
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
