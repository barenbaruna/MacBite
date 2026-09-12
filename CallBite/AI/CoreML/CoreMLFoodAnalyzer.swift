//
//  CoreMLFoodAnalyzer.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//
//  Production `FoodAnalyzing` implementation, orchestrating the full pipeline
//  ported from FoodNutritionPOC:
//
//    Image -> ImagePreprocessingService -> FoodGateService (food/non-food)
//          -> if food: NutritionRegressionService + VisionEvidenceExtractor
//             (naming) run in parallel -> combined into one FoodCandidate
//

import UIKit

public final class CoreMLFoodAnalyzer: FoodAnalyzing, @unchecked Sendable {

    // MARK: - Dependencies

    // Optional + loaded eagerly at init via `try?` rather than a throwing init:
    // this type is used as a default parameter value in DashboardViewModel's
    // initializer, which requires a non-throwing expression. A load failure
    // (missing/corrupt .mlpackage) surfaces as `.modelNotFound` on first
    // `analyze(_:)` call instead of at construction time.
    private let gateService: FoodGateService?
    private let nutritionService: NutritionRegressionService?
    private let visionExtractor = VisionEvidenceExtractor()

    // MARK: - Init

    public init() {
        gateService = try? FoodGateService()
        nutritionService = try? NutritionRegressionService()
    }

    // MARK: - FoodAnalyzing

    public func analyze(_ image: UIImage) async throws -> FoodCandidate {
        guard let gateService, let nutritionService else {
            throw AppError.modelNotFound("FoodGate / NutritionADMD")
        }

        // Step 1: food/non-food gate.
        let gateResult = try await Task.detached(priority: .userInitiated) {
            try gateService.classify(image)
        }.value

        guard gateResult.isFood else {
            throw AppError.nonFoodDetected(probability: gateResult.foodProbability)
        }

        // Step 2: nutrition regression + dish naming run in parallel — naming
        // does not depend on the nutrition numbers, and vice versa.
        async let nutritionTask = Task.detached(priority: .userInitiated) {
            try nutritionService.predict(image)
        }.value

        async let namingTask = visionExtractor.identify(from: image)

        let (regression, naming) = try await (nutritionTask, namingTask)

        let nutrition = NutritionFacts(
            calories: Int(regression.calories.rounded()),
            protein: Int(regression.protein.rounded()),
            carbs: Int(regression.carbs.rounded()),
            fat: Int(regression.fat.rounded()),
            fiber: 0 // NutritionADMD does not predict fiber — documented model limitation.
        )

        return FoodCandidate(
            name: naming.name,
            components: naming.components,
            nutrition: nutrition,
            portionGrams: regression.massGrams,
            foodProbability: gateResult.foodProbability
        )
    }
}
