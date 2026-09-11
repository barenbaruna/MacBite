//
//  FoodAnalyzing.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//

import Foundation

/// Pure domain descriptor of an ingredient for AI/ML analysis.
public struct IngredientDescriptor: Equatable, Hashable, Sendable {
    public let name: String
    public let portionGrams: Double
    public let cookingMethod: String?

    public init(name: String, portionGrams: Double, cookingMethod: String? = nil) {
        self.name = name
        self.portionGrams = portionGrams
        self.cookingMethod = cookingMethod
    }
}

/// Protocol defining the contract for AI/ML food analysis across Core ML, Foundation Models, and Mocks.
public protocol FoodAnalyzing: Sendable {
    func analyzePhoto(imageData: Data) async throws -> FoodItem
    func analyzeManual(name: String, ingredients: [IngredientDescriptor]) async throws -> FoodItem
}
