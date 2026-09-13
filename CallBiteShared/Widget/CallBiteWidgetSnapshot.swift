//
//  CallBiteWidgetSnapshot.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import Foundation

struct CallBiteWidgetSnapshot: Codable, Equatable, Sendable {
    let date: Date
    let consumedCalories: Int
    let targetCalories: Int
    let proteinGrams: Int
    let targetProteinGrams: Int
    let carbsGrams: Int
    let targetCarbsGrams: Int
    let fatGrams: Int
    let targetFatGrams: Int
    let updatedAt: Date

    var remainingCalories: Int {
        max(0, targetCalories - consumedCalories)
    }

    var hasNutritionGoal: Bool {
        targetCalories > 0
    }

    func valuesForToday(_ today: Date = .now, calendar: Calendar = .current) -> Self {
        guard !calendar.isDate(date, inSameDayAs: today) else { return self }

        return CallBiteWidgetSnapshot(
            date: today,
            consumedCalories: 0,
            targetCalories: targetCalories,
            proteinGrams: 0,
            targetProteinGrams: targetProteinGrams,
            carbsGrams: 0,
            targetCarbsGrams: targetCarbsGrams,
            fatGrams: 0,
            targetFatGrams: targetFatGrams,
            updatedAt: updatedAt
        )
    }

    static func empty(for date: Date = .now) -> Self {
        CallBiteWidgetSnapshot(
            date: date,
            consumedCalories: 0,
            targetCalories: 0,
            proteinGrams: 0,
            targetProteinGrams: 0,
            carbsGrams: 0,
            targetCarbsGrams: 0,
            fatGrams: 0,
            targetFatGrams: 0,
            updatedAt: date
        )
    }
}
