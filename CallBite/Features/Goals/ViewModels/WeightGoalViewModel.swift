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
    private var previousZone: WeightRangeZone?

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

    var healthyWeightRange: ClosedRange<Double> {
        ScientificWeightEngine.healthyWeightRange(heightCm: heightCm)
    }

    var currentZone: WeightRangeZone {
        if targetWeightKg < healthyWeightRange.lowerBound {
            return .belowRecommended
        } else if targetWeightKg > healthyWeightRange.upperBound {
            return .aboveRecommended
        } else {
            return .recommended
        }
    }

    var currentZoneColor: Color {
        switch currentZone {
        case .belowRecommended: return AppColor.goalCyan
        case .recommended: return AppColor.goalGreen
        case .aboveRecommended: return AppColor.goalCoral
        }
    }

    init(currentWeightKg: Double = 60.0, targetWeightKg: Double? = nil, heightCm: Double = 168.0) {
        self.currentWeightKg = currentWeightKg
        self.heightCm = heightCm
        let initialTarget = targetWeightKg ?? ScientificWeightEngine.recommendedInitialTarget(
            currentWeightKg: currentWeightKg,
            heightCm: heightCm
        )
        self.targetWeightKg = initialTarget
        self.previousCategory = ScientificWeightEngine.evaluate(
            currentWeightKg: currentWeightKg,
            targetWeightKg: initialTarget,
            heightCm: heightCm
        ).category
        let range = ScientificWeightEngine.healthyWeightRange(heightCm: heightCm)
        if initialTarget < range.lowerBound {
            self.previousZone = .belowRecommended
        } else if initialTarget > range.upperBound {
            self.previousZone = .aboveRecommended
        } else {
            self.previousZone = .recommended
        }
    }

    private func handleWeightChange() {
        let newCategory = insight.category
        if newCategory != previousCategory {
            previousCategory = newCategory
            triggerCategoryHaptic.toggle()
        }

        let newZone = currentZone
        if let prev = previousZone, newZone != prev {
            AppHaptics.boundaryCrossed()
        }
        previousZone = newZone
    }

    var activeButtonColor: Color {
        switch activeCategory {
        case .cutting: return AppColor.goalCyan
        case .maintaining: return AppColor.goalGreen
        case .bulking: return AppColor.goalCoral
        }
    }
}
