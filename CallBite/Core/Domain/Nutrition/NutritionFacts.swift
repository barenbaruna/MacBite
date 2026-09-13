//
//  NutritionFacts.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Macronutrient and caloric energy values computed from foods or entered by the user.
public struct NutritionFacts: Equatable, Hashable, Sendable, Codable {
    public var calories: Int
    public var protein: Int
    public var carbs: Int
    public var fat: Int
    public var fiber: Int

    public init(
        calories: Int = 0,
        protein: Int = 0,
        carbs: Int = 0,
        fat: Int = 0,
        fiber: Int = 0
    ) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
    }

    public static let zero = NutritionFacts(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0)
}
