//
//  WeightGoalFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

enum WeightGoalFactory {
    static func createView(
        currentWeightKg: Double = 60.0,
        targetWeightKg: Double = 56.0,
        heightCm: Double = 168.0,
        onDone: ((Double, GoalCategory) -> Void)? = nil
    ) -> some View {
        WeightGoalView(
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            heightCm: heightCm,
            onDone: onDone
        )
    }
}
