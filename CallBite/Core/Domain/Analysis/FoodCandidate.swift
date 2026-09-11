//
//  FoodCandidate.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//

import Foundation

/// Result of an AI food analysis pass over a single captured photo.
///
/// This is the analyzer's raw output — separate from `FoodItem` (the persisted/
/// displayed domain model). A `FoodCandidate` is mapped into a `FoodItem` by the
/// caller (see `DashboardViewModel.mapToFoodItem`) before being logged.
public struct FoodCandidate: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    /// Dish name inferred by the analyzer (e.g. "Fried Chicken with Rice").
    public var name: String
    /// Detected side dishes/ingredients. Not yet surfaced in any View —
    /// captured here so a future UI can display them without re-touching the analyzer.
    public var components: [String]
    /// Macronutrient estimate. Reuses the existing `NutritionFacts` domain model.
    /// NOTE: `fiber` is always 0 — the underlying regression model (NutritionADMD)
    /// does not predict fiber, only calories/mass/fat/carbs/protein.
    public var nutrition: NutritionFacts
    /// Estimated portion mass in grams from the regression model. Not yet
    /// surfaced in any View.
    public var portionGrams: Double
    /// Food/non-food gate probability (0...1) from the CoreML food-gate model.
    /// Kept for transparency/debugging; not required for the happy path.
    public var foodProbability: Double

    public init(
        id: UUID = UUID(),
        name: String,
        components: [String] = [],
        nutrition: NutritionFacts,
        portionGrams: Double = 0,
        foodProbability: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.components = components
        self.nutrition = nutrition
        self.portionGrams = portionGrams
        self.foodProbability = foodProbability
    }
}
