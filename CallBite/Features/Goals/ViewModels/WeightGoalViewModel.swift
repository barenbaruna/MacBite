//
//  WeightGoalViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// ViewModel managing user weight goal targets and real-time scientific insights.
@Observable
final class WeightGoalViewModel {
    var currentWeightKg: Double = 60.0
    var heightCm: Double = 168.0

    var targetWeightKg: Double = 56.0 {
        didSet {
            handleWeightChange()
        }
    }

    let minSliderWeight: Double = 40.0
    let maxSliderWeight: Double = 90.0

    var triggerCategoryHaptic: Bool = false

    private var previousCategory: GoalCategory = .cutting

    var insight: ScientificGoalInsight {
        ScientificWeightEngine.evaluate(
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            heightCm: heightCm
        )
    }

    var activeCategory: GoalCategory {
        insight.category
    }

    init(currentWeightKg: Double = 60.0, targetWeightKg: Double = 56.0, heightCm: Double = 168.0) {
        self.currentWeightKg = currentWeightKg
        self.targetWeightKg = targetWeightKg
        self.heightCm = heightCm
        self.previousCategory = ScientificWeightEngine.evaluate(
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            heightCm: heightCm
        ).category
    }

    private func handleWeightChange() {
        let newCategory = insight.category
        if newCategory != previousCategory {
            previousCategory = newCategory
            triggerCategoryHaptic.toggle()
        }
    }

    var activeButtonColor: Color {
        switch activeCategory {
        case .cutting: return AppColor.goalCyan
        case .maintaining: return AppColor.goalGreen
        case .bulking: return AppColor.goalCoral
        }
    }

    var healthyWeightRange: ClosedRange<Double> {
        ScientificWeightEngine.healthyWeightRange(heightCm: heightCm)
    }
}
