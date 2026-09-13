//
//  MockFoodAnalyzer.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//
//  Mock implementation of `FoodAnalyzing` for unit tests and SwiftUI previews,
//  so ViewModel tests don't need to run real CoreML/Foundation Models inference.
//

import UIKit

final class MockFoodAnalyzer: FoodAnalyzing, @unchecked Sendable {
    var resultToReturn: FoodCandidate
    var errorToThrow: AppError?

    init(
        resultToReturn: FoodCandidate = MockFoodAnalyzer.defaultCandidate,
        errorToThrow: AppError? = nil
    ) {
        self.resultToReturn = resultToReturn
        self.errorToThrow = errorToThrow
    }

    func analyze(_ image: UIImage) async throws -> FoodCandidate {
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }

    static let defaultCandidate = FoodCandidate(
        name: "Grilled Chicken with Rice",
        components: ["Grilled Chicken", "Steamed Rice", "Mixed Vegetables"],
        nutrition: NutritionFacts(calories: 480, protein: 32, carbs: 55, fat: 12, fiber: 0),
        portionGrams: 320,
        foodProbability: 0.94
    )
}
