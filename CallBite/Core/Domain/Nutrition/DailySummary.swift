//
//  DailySummary.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Daily progress summary of caloric intake and macronutrient totals against target goals.
public struct DailySummary: Equatable, Hashable, Sendable {
    public var dateString: String
    public var targetCalories: Int
    public var consumedCalories: Int
    public var targetCarbs: Int
    public var targetProtein: Int
    public var targetFat: Int
    public var targetFiber: Int
    public var totalCarbs: Int
    public var totalProtein: Int
    public var totalFat: Int
    public var totalFiber: Int
    public var streakDays: Int

    public var remainingCalories: Int {
        max(0, targetCalories - consumedCalories)
    }

    public var progressRatio: Double {
        guard targetCalories > 0 else { return 0.0 }
        return min(1.0, Double(consumedCalories) / Double(targetCalories))
    }

    public init(
        dateString: String = "Today, 4 Sep 2026",
        targetCalories: Int = 2654,
        consumedCalories: Int = 200,
        targetCarbs: Int = 300,
        targetProtein: Int = 70,
        targetFat: Int = 70,
        targetFiber: Int = 70,
        totalCarbs: Int = 17,
        totalProtein: Int = 14,
        totalFat: Int = 17,
        totalFiber: Int = 100,
        streakDays: Int = 0
    ) {
        self.dateString = dateString
        self.targetCalories = targetCalories
        self.consumedCalories = consumedCalories
        self.targetCarbs = targetCarbs
        self.targetProtein = targetProtein
        self.targetFat = targetFat
        self.targetFiber = targetFiber
        self.totalCarbs = totalCarbs
        self.totalProtein = totalProtein
        self.totalFat = totalFat
        self.totalFiber = totalFiber
        self.streakDays = streakDays
    }

    public static let sampleDashboard = DailySummary(
        dateString: "Today, 4 Sep 2026",
        targetCalories: 2654,
        consumedCalories: 200,
        totalCarbs: 17,
        totalProtein: 14,
        totalFat: 17,
        totalFiber: 100,
        streakDays: 0
    )
}
