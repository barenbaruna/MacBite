//
//  NutritionEstimating.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Contract for estimating nutrition from a manually-typed meal description
//  (no photo). Separate from `FoodAnalyzing` (which takes a `UIImage`) —
//  manual logging has no image, only text the user typed.
//
//  A protocol exists here for the same reason as `FoodAnalyzing`: this runs
//  ML inference (09_Dependency_Injection.md: "Service menjalankan inferensi
//  ML model -- buat protocol"), so it needs to be mockable for ViewModel
//  tests without invoking real Foundation Models inference.
//
//  LANGUAGE ASSUMPTION: manual input is expected in English. Testing found
//  that Apple Intelligence's on-device model rejects prompts with
//  ".unsupportedLanguageOrLocale" once enough non-English proper nouns are
//  present (e.g. several Indonesian ingredient names), even with fully
//  English instructions/scaffolding around them — confirmed via a spike
//  before this file was written. No translation/mitigation layer is built
//  here per product decision: users are expected to type ingredients in
//  English. If that assumption changes, add a translation step (e.g. a
//  small ID->EN lookup table, or the `Translation` framework) BEFORE
//  building the prompt in `FoundationModelNutritionEstimator`.

/// A single ingredient in a manually-described meal, decoupled from
/// `Features/ManualLogging/Models/ManualIngredientInput` (which is
/// string-based UI state) so this Core/Domain protocol never depends on a
/// Feature-specific model (01_Architecture.md: "Feature -> Core, tidak
/// pernah sebaliknya").
public struct ManualMealDescription: Sendable {
    public struct Ingredient: Sendable {
        public let name: String
        public let portionGrams: Double?
        public let cookingMethod: String?

        public init(name: String, portionGrams: Double?, cookingMethod: String?) {
            self.name = name
            self.portionGrams = portionGrams
            self.cookingMethod = cookingMethod
        }
    }

    public let foodName: String
    public let ingredients: [Ingredient]

    public init(foodName: String, ingredients: [Ingredient]) {
        self.foodName = foodName
        self.ingredients = ingredients
    }
}

public protocol NutritionEstimating: Sendable {
    /// Estimates total nutrition facts for a manually-described meal.
    ///
    /// - Throws: `AppError` if the model is unavailable or inference fails.
    ///   Caller should fall back to a non-AI estimate rather than dead-ending.
    func estimate(_ meal: ManualMealDescription) async throws -> NutritionFacts
}
