//
//  GoalCalculator.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Foundation

/// Scientific calculator for Basal Metabolic Rate (BMR), Total Daily Energy Expenditure (TDEE), and Nutrition Goals.
enum GoalCalculator {
    /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
    /// - Male: (10 × weight) + (6.25 × height) - (5 × age) + 5
    /// - Female: (10 × weight) + (6.25 × height) - (5 × age) - 161
    /// - Prefer Not To Say: (10 × weight) + (6.25 × height) - (5 × age) - 78
    ///   (Calculated using midpoint average: (5 + (-161)) / 2 = -78)
    static func calculateBMR(
        weightKg: Double,
        heightCm: Double,
        age: Int,
        sex: BiologicalSex
    ) -> Double {
        guard weightKg > 0, heightCm > 0, age > 0 else { return 0.0 }
        let base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age))
        return max(0.0, base + sex.bmrConstant)
    }

    /// Convenience overload using UserHealthProfile.
    static func calculateBMR(profile: UserHealthProfile) -> Double {
        calculateBMR(
            weightKg: profile.weightKg,
            heightCm: profile.heightCm,
            age: profile.age,
            sex: profile.biologicalSex
        )
    }

    /// Calculates Total Daily Energy Expenditure (TDEE).
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        max(0.0, bmr * activityLevel.multiplier)
    }

    /// Calculates TDEE directly from health profile and activity level.
    static func calculateTDEE(profile: UserHealthProfile, activityLevel: ActivityLevel) -> Double {
        let bmr = calculateBMR(profile: profile)
        return calculateTDEE(bmr: bmr, activityLevel: activityLevel)
    }

    /// Calculates daily caloric intake target based on TDEE and weight goal category.
    static func calculateDailyCalorieTarget(
        tdee: Double,
        category: GoalCategory
    ) -> Int {
        let adjustment: Double
        switch category {
        case .cutting:
            adjustment = -500.0
        case .maintaining:
            adjustment = 0.0
        case .bulking:
            adjustment = 300.0
        }
        return max(1200, Int((tdee + adjustment).rounded()))
    }

    /// Calculates balanced macro goals (45% Carbs, 25% Protein, 30% Fat) for the daily calorie target.
    static func calculateMacronutrients(dailyCalories: Int) -> NutritionGoal {
        let caloriesDouble = Double(dailyCalories)
        let carbsCalories = caloriesDouble * 0.45
        let proteinCalories = caloriesDouble * 0.25
        let fatCalories = caloriesDouble * 0.30

        let carbsGrams = Int((carbsCalories / 4.0).rounded())
        let proteinGrams = Int((proteinCalories / 4.0).rounded())
        let fatGrams = Int((fatCalories / 9.0).rounded())

        return NutritionGoal(
            targetCalories: dailyCalories,
            targetCarbsGrams: carbsGrams,
            targetProteinGrams: proteinGrams,
            targetFatGrams: fatGrams,
            targetFiberGrams: 28
        )
    }
}
