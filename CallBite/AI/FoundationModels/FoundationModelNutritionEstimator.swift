//
//  FoundationModelNutritionEstimator.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Estimates total nutrition for a manually-typed meal (name + ingredients +
//  gram portions + cooking method) using Apple's on-device Foundation Model.
//  No Vision/CoreML involved here — the input is already structured text
//  from the user, not an ambiguous photo.
//
//  LANGUAGE ASSUMPTION: manual input is expected in English. A pre-implementation
//  spike confirmed the on-device model throws `.unsupportedLanguageOrLocale`
//  once enough non-English proper nouns appear in the prompt (tested with
//  Indonesian ingredient names), even with fully English instructions around
//  them — this is NOT just about the instructions being English, the overall
//  language mix of instructions+prompt matters. Per product decision, this
//  estimator does not translate input; if that assumption changes later, add
//  a translation step BEFORE `buildPrompt` (e.g. a small ID->EN lookup, or the
//  `Translation` framework), not inside the prompt-building logic itself.
//

import Foundation
import FoundationModels

public final class FoundationModelNutritionEstimator: NutritionEstimating, @unchecked Sendable {

    // MARK: - Generation Schema

    @Generable
    struct EstimatedNutrition {
        @Guide(description: """
        Total calories in kcal for the entire meal, computed as the SUM of each \
        ingredient's own calorie estimate (based on that ingredient's specific \
        gram portion and cooking method) — not a single per-100g rate applied \
        to the whole meal.
        """)
        var calories: Int

        @Guide(description: "Total estimated protein in grams for the entire meal.")
        var protein: Int

        @Guide(description: "Total estimated carbohydrates in grams for the entire meal.")
        var carbs: Int

        @Guide(description: "Total estimated fat in grams for the entire meal.")
        var fat: Int

        @Guide(description: "Total estimated dietary fiber in grams for the entire meal.")
        var fiber: Int
    }

    // MARK: - Availability

    /// Whether Apple Intelligence / Foundation Models is actually usable on
    /// this device right now. CallBite's deployment target is already iOS
    /// 26.5, so no `@available` compile-time guard is needed — this is a
    /// runtime check only (device eligibility / Apple Intelligence toggle).
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // MARK: - Session

    private static let instructions = """
    You estimate total nutrition facts for a meal from its name and a list of \
    ingredients with gram portions and cooking methods.

    BOTH the meal name and the ingredient list matter, and you should use them \
    together:
    - The meal name gives you the overall dish identity/context — it can imply \
      typical accompaniments or preparation details (e.g. oil, seasoning, sauce) \
      that aren't spelled out as separate ingredient entries.
    - Each ingredient's OWN gram portion and cooking method tells you specifically \
      how THAT ingredient was prepared — use it to adjust that ingredient's \
      estimate (e.g. fried adds more fat than steamed/boiled/grilled for the same \
      ingredient). Do not apply one ingredient's cooking method to a different one.

    To produce an accurate total, work ingredient by ingredient: for EACH \
    ingredient, first estimate its own calories/protein/carbs/fat/fiber using \
    typical macros per 100g for that ingredient, adjusted for its specific \
    gram portion and cooking method, while keeping the overall meal name in mind \
    for context. THEN sum all ingredients together into ONE combined total for \
    the whole meal — the final numbers you output must be that sum, not a single \
    rate applied to the meal as a whole.

    Rules:
    - Assume standard/typical nutrition values for named ingredients. If an
      ingredient is unclear or unfamiliar, make a reasonable estimate rather
      than refusing to answer.
    - If a portion size is missing for an ingredient, assume a typical serving
      size for that ingredient rather than treating it as zero.
    - Never return negative values.
    """

    private let session: LanguageModelSession

    public init() {
        session = LanguageModelSession(instructions: Self.instructions)
    }

    // MARK: - NutritionEstimating

    public func estimate(_ meal: ManualMealDescription) async throws -> NutritionFacts {
        guard !meal.ingredients.isEmpty else {
            throw AppError.inferenceFailed("No ingredients to estimate.")
        }
        guard Self.isAvailable else {
            throw AppError.modelNotFound("Foundation Models (Apple Intelligence)")
        }

        let prompt = buildPrompt(for: meal)

        do {
            // sampling: .greedy — same determinism fix as FoundationModelFoodNamer:
            // without it, the exact same meal description could yield a different
            // estimate on every run.
            let response = try await session.respond(
                to: prompt,
                generating: EstimatedNutrition.self,
                options: GenerationOptions(sampling: .greedy)
            )
            let result = response.content
            return NutritionFacts(
                calories: max(0, result.calories),
                protein: max(0, result.protein),
                carbs: max(0, result.carbs),
                fat: max(0, result.fat),
                fiber: max(0, result.fiber)
            )
        } catch {
            throw AppError.inferenceFailed("Foundation Model failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Prompt Building

    private func buildPrompt(for meal: ManualMealDescription) -> String {
        let ingredientLines = meal.ingredients.enumerated().map { index, ingredient in
            formatIngredientLine(ingredient, index: index)
        }.joined(separator: "\n")

        return """
        Meal name: "\(meal.foodName)".
        Ingredients:
        \(ingredientLines)
        Estimate total calories, protein (g), carbs (g), fat (g), and fiber (g) for this meal.
        """
    }

    private func formatIngredientLine(_ ingredient: ManualMealDescription.Ingredient, index: Int) -> String {
        var parts: [String] = ["\"\(ingredient.name)\""]

        if let grams = ingredient.portionGrams {
            parts.append("\(Int(grams))g")
        }
        if let method = ingredient.cookingMethod, !method.isEmpty {
            parts.append("cooking method: \(method)")
        }

        return "\(index + 1)) \(parts.joined(separator: ", "))."
    }
}
