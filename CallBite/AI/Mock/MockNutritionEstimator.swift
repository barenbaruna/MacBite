//
//  MockNutritionEstimator.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Mock implementation of `NutritionEstimating` for unit tests and SwiftUI
//  previews, so ViewModel tests don't need to run real Foundation Models
//  inference.
//

final class MockNutritionEstimator: NutritionEstimating, @unchecked Sendable {
    var resultToReturn: NutritionFacts
    var errorToThrow: AppError?

    init(
        resultToReturn: NutritionFacts = MockNutritionEstimator.defaultResult,
        errorToThrow: AppError? = nil
    ) {
        self.resultToReturn = resultToReturn
        self.errorToThrow = errorToThrow
    }

    func estimate(_ meal: ManualMealDescription) async throws -> NutritionFacts {
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }

    static let defaultResult = NutritionFacts(calories: 540, protein: 35, carbs: 48, fat: 20, fiber: 3)
}
