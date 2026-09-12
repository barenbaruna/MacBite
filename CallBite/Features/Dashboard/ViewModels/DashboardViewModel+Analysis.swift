//
//  DashboardViewModel+Analysis.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import SwiftUI
import UIKit

// MARK: - AI Nutrition Analysis

extension DashboardViewModel {
    public func resetAndOpenAddFood() {
        var food = FoodItem.dimsumMentai
        food.mealType = FoodItem.currentMealType()
        food.dateString = FoodItem.currentDateString()
        resetAndOpenAddFood(with: food)
    }

    public func resetAndOpenAddFood(with food: FoodItem) {
        currentFood = food
        isCardCompressed = false
        flipAngle = 0.0
        morphProgress = 0.0
        cardContentOpacity = 1.0
        orbGlowOpacity = 0.0
        orbScale = 1.0
        orbBlur = 0.0
        cardOffsetX = 0.0
        cardOffsetY = 0.0
        rippleScale = 0.5
        rippleOpacity = 0.0
        let currentRatio = CGFloat(dailySummary.consumedCalories) / CGFloat(max(1, dailySummary.targetCalories))
        ringProgress = currentRatio
        orbProgress = Double(currentRatio)
        ringScale = 1.0
        phase = .idle

        withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
            isShowingAddFood = true
        }
    }

    public func toggleLoggingOptions() {
        isShowingLoggingOptions.toggle()
    }

    public func hideLoggingOptions() {
        isShowingLoggingOptions = false
    }

    /// Analyzes a captured or selected food photo and opens the review card with the result.
    @discardableResult
    public func analyzeCapturedPhoto(_ image: UIImage) async -> Bool {
        isAnalyzing = true
        analysisMessage = "Analyzing your meal…"

        do {
            let candidate = try await foodAnalyzer.analyze(image)
            openAddFoodCard(with: mapToFoodItem(candidate, photo: image))
            return true
        } catch AppError.nonFoodDetected(let probability) {
            isAnalyzing = false
            let percent = Int((probability * 100).rounded())
            nonFoodWarningMessage = "This photo wasn't detected as food (\(percent)% confidence). " +
                "Please retake the photo with the food clearly visible."
            return false
        } catch {
            var fallback = FoodItem.dimsumMentai
            fallback.mealType = FoodItem.currentMealType()
            fallback.dateString = FoodItem.currentDateString()
            fallback.photoData = image.jpegData(compressionQuality: 0.8)
            openAddFoodCard(with: fallback)
            return true
        }
    }

    public func dismissNonFoodWarning() {
        nonFoodWarningMessage = nil
    }

    /// Estimates nutrition for a manually typed meal, with ratio math as a safe fallback.
    func calculateManualNutrition(name: String, ingredients: [ManualIngredientInput]) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isAnalyzing = true
        analysisMessage = "Estimating nutrition…"

        let meal = mapToMealDescription(name: trimmed, ingredients: ingredients)

        #if DEBUG
        print(
            "[ManualNutrition] called on \(ObjectIdentifier(self)) " +
                "with name=\"\(name)\" rawIngredientCount=\(ingredients.count)"
        )
        let ingredientDescription = meal.ingredients.map {
            "\($0.name)/\($0.portionGrams ?? -1)g"
        }
        print(
            "[ManualNutrition] mapped meal: foodName=\"\(meal.foodName)\" " +
                "ingredients=\(ingredientDescription)"
        )
        #endif

        do {
            let nutrition = try await nutritionEstimator.estimate(meal)
            #if DEBUG
            print("[ManualNutrition] Foundation Model SUCCESS -> \(nutrition)")
            #endif
            openAddFoodCard(with: mapToFoodItem(name: meal.foodName, nutrition: nutrition))
        } catch {
            #if DEBUG
            print(
                "[ManualNutrition] Foundation Model FAILED: \(error). " +
                    "Falling back to legacy ratio math."
            )
            #endif
            openAddFoodCard(with: legacyRatioEstimate(name: name, ingredients: ingredients))
        }
    }

    private func openAddFoodCard(with food: FoodItem) {
        #if DEBUG
        print(
            "[ManualNutrition] openAddFoodCard firing on " +
                "\(ObjectIdentifier(self)), setting isShowingAddFood=true"
        )
        #endif
        self.isAnalyzing = false
        self.resetAndOpenAddFood(with: food)
    }

    private func mapToFoodItem(_ candidate: FoodCandidate, photo: UIImage) -> FoodItem {
        FoodItem(
            name: candidate.name,
            mealType: FoodItem.currentMealType(),
            dateString: FoodItem.currentDateString(),
            calories: candidate.nutrition.calories,
            protein: candidate.nutrition.protein,
            carbs: candidate.nutrition.carbs,
            fat: candidate.nutrition.fat,
            fiber: candidate.nutrition.fiber,
            photoSystemName: "camera.fill",
            photoData: photo.jpegData(compressionQuality: 0.8)
        )
    }

    private func mapToMealDescription(
        name: String,
        ingredients: [ManualIngredientInput]
    ) -> ManualMealDescription {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let mealName = trimmedName.isEmpty ? "Meal" : trimmedName
        let mapped = ingredients.compactMap { input -> ManualMealDescription.Ingredient? in
            let trimmedIngredient = input.ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIngredient.isEmpty else { return nil }

            // NOTE: input.cookingMethod (still a valid UI field) is intentionally
            // not mapped — see the language note atop FoundationModelNutritionEstimator.
            return ManualMealDescription.Ingredient(
                name: trimmedIngredient,
                portionGrams: Double(input.portionGrams.trimmingCharacters(in: .whitespacesAndNewlines))
            )
        }

        return ManualMealDescription(foodName: mealName, ingredients: mapped)
    }

    private func mapToFoodItem(name: String, nutrition: NutritionFacts) -> FoodItem {
        FoodItem(
            name: name,
            mealType: FoodItem.currentMealType(),
            dateString: FoodItem.currentDateString(),
            calories: nutrition.calories,
            protein: nutrition.protein,
            carbs: nutrition.carbs,
            fat: nutrition.fat,
            fiber: nutrition.fiber,
            photoSystemName: "fork.knife"
        )
    }

    private func legacyRatioEstimate(name: String, ingredients: [ManualIngredientInput]) -> FoodItem {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmed.isEmpty ? "Meal" : trimmed
        let totalGrams = ingredients.compactMap { Int($0.portionGrams) }.reduce(0, +)
        let baseGrams = totalGrams > 0 ? totalGrams : 100
        let ratio = Double(baseGrams) / 100.0

        return FoodItem(
            name: displayName,
            mealType: FoodItem.currentMealType(),
            dateString: FoodItem.currentDateString(),
            calories: max(50, Int(220.0 * ratio)),
            protein: max(5, Int(15.0 * ratio)),
            carbs: max(5, Int(25.0 * ratio)),
            fat: max(2, Int(8.0 * ratio)),
            fiber: max(1, Int(2.0 * ratio)),
            photoSystemName: "fork.knife"
        )
    }
}
