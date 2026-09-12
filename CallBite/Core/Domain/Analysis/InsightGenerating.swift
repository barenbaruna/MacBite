//
//  InsightGenerating.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 12/09/26.
//
//  Contract for generating a short coaching message from the user's daily
//  progress (remaining calories + macronutrient fulfillment). Mirrors
//  `FoodAnalyzing`/`NutritionEstimating` — a protocol exists here for the
//  same reason: this runs ML inference (09_Dependency_Injection.md: "Service
//  menjalankan inferensi ML model -- buat protocol"), so it needs to be
//  mockable for ViewModel tests without invoking real Foundation Models
//  inference. Takes `DailySummary` directly — it's already a Core/Domain
//  type, so no cross-feature dependency concern here (unlike
//  `NutritionEstimating`, which needed its own `ManualMealDescription`).
//

public protocol InsightGenerating: Sendable {
    /// Generates a short (1-2 sentence) coaching insight from a day's
    /// calorie/macro progress against targets.
    ///
    /// - Throws: `AppError` if the model is unavailable or inference fails.
    ///   Caller should fall back to a rule-based message rather than
    ///   dead-ending or showing a blank insight.
    func generateInsight(for summary: DailySummary) async throws -> String
}
