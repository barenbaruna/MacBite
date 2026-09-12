//
//  MockInsightGenerator.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 12/09/26.
//
//  Mock implementation of `InsightGenerating` for unit tests and SwiftUI
//  previews, so ViewModel tests don't need to run real Foundation Models
//  inference.
//

final class MockInsightGenerator: InsightGenerating, @unchecked Sendable {
    var resultToReturn: String
    var errorToThrow: AppError?

    init(
        resultToReturn: String = "You're doing great — keep it up!",
        errorToThrow: AppError? = nil
    ) {
        self.resultToReturn = resultToReturn
        self.errorToThrow = errorToThrow
    }

    func generateInsight(for summary: DailySummary) async throws -> String {
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }
}
