//
//  NutritionGoal.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Foundation

/// Target nutrition goals including daily calories and macronutrient breakdown in grams.
public struct NutritionGoal: Equatable, Hashable, Codable, Sendable {
    public var targetCalories: Int
    public var targetCarbsGrams: Int
    public var targetProteinGrams: Int
    public var targetFatGrams: Int
    public var targetFiberGrams: Int

    public init(
        targetCalories: Int,
        targetCarbsGrams: Int,
        targetProteinGrams: Int,
        targetFatGrams: Int,
        targetFiberGrams: Int = 28
    ) {
        self.targetCalories = targetCalories
        self.targetCarbsGrams = targetCarbsGrams
        self.targetProteinGrams = targetProteinGrams
        self.targetFatGrams = targetFatGrams
        self.targetFiberGrams = targetFiberGrams
    }
}
