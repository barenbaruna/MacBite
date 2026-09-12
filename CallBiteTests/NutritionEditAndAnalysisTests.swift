//
//  NutritionEditAndAnalysisTests.swift
//  CallBiteTests
//
//  Created by Codex on 11/09/26.
//

@testable import CallBite
import Foundation
import Testing
import UIKit

@Suite("NutritionEditTests")
struct NutritionEditTests {
    @Test func testNutritionEditFieldProperties() {
        #expect(NutritionEditField.calories.unit == "kcal")
        #expect(NutritionEditField.protein.unit == "g")
        #expect(NutritionEditField.carbs.unit == "g")
        #expect(NutritionEditField.fat.unit == "g")
        #expect(NutritionEditField.fiber.unit == "g")
        #expect(NutritionEditField.allCases.count == 5)
    }

    @Test func testFreeTextNumberParsing() {
        let rawInputs = ["500", "  250 ", "abc45xyz", "0", ""]
        let parsed = rawInputs.map { input in
            let digitsOnly = input.filter { $0.isNumber }
            return max(0, Int(digitsOnly) ?? 0)
        }
        #expect(parsed == [500, 250, 45, 0, 0])
    }
}

@Suite("FoodAnalyzerTests")
struct FoodAnalyzerTests {
    @Test func testMockFoodAnalyzerReturnsCandidate() async throws {
        let expectedCandidate = FoodCandidate(
            name: "Grilled Chicken Bowl",
            components: ["Grilled Chicken", "Brown Rice"],
            nutrition: NutritionFacts(
                calories: 680,
                protein: 48,
                carbs: 65,
                fat: 18,
                fiber: 6
            ),
            portionGrams: 350,
            foodProbability: 0.94
        )
        let analyzer = MockFoodAnalyzer(resultToReturn: expectedCandidate)

        let candidate = try await analyzer.analyze(UIImage())

        #expect(candidate == expectedCandidate)
    }

    @Test func testMockNutritionEstimatorReturnsNutrition() async throws {
        let expectedNutrition = NutritionFacts(
            calories: 460,
            protein: 30,
            carbs: 40,
            fat: 15,
            fiber: 2
        )
        let estimator = MockNutritionEstimator(resultToReturn: expectedNutrition)
        let meal = ManualMealDescription(
            foodName: "Chicken & Rice",
            ingredients: [
                .init(name: "Chicken Breast", portionGrams: 150),
                .init(name: "Brown Rice", portionGrams: 100)
            ]
        )

        let nutrition = try await estimator.estimate(meal)

        #expect(nutrition == expectedNutrition)
    }

    @Test func testMockInsightGeneratorReturnsInsight() async throws {
        let generator = MockInsightGenerator(resultToReturn: "You're on track — keep it up!")
        let summary = DailySummary(targetCalories: 2000, consumedCalories: 1500)

        let insight = try await generator.generateInsight(for: summary)

        #expect(insight == "You're on track — keep it up!")
    }
}

@Suite("MealTimeSlotTests")
struct MealTimeSlotTests {
    private func date(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 11
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    @Test func testTimeBoundaries() {
        // Breakfast: 05.00 – 10.59
        #expect(MealTimeSlot.slot(for: date(hour: 5, minute: 0)) == .breakfast)
        #expect(MealTimeSlot.slot(for: date(hour: 8, minute: 30)) == .breakfast)
        #expect(MealTimeSlot.slot(for: date(hour: 10, minute: 59)) == .breakfast)

        // Lunch: 11.00 – 15.59
        #expect(MealTimeSlot.slot(for: date(hour: 11, minute: 0)) == .lunch)
        #expect(MealTimeSlot.slot(for: date(hour: 13, minute: 15)) == .lunch)
        #expect(MealTimeSlot.slot(for: date(hour: 15, minute: 59)) == .lunch)

        // Dinner: 16.00 – 20.59
        #expect(MealTimeSlot.slot(for: date(hour: 16, minute: 0)) == .dinner)
        #expect(MealTimeSlot.slot(for: date(hour: 18, minute: 45)) == .dinner)
        #expect(MealTimeSlot.slot(for: date(hour: 20, minute: 59)) == .dinner)

        // Snack / Late Night: 21.00 – 04.59
        #expect(MealTimeSlot.slot(for: date(hour: 21, minute: 0)) == .snackLateNight)
        #expect(MealTimeSlot.slot(for: date(hour: 23, minute: 30)) == .snackLateNight)
        #expect(MealTimeSlot.slot(for: date(hour: 0, minute: 0)) == .snackLateNight)
        #expect(MealTimeSlot.slot(for: date(hour: 4, minute: 59)) == .snackLateNight)
    }

    @Test func testGreetingMessages() {
        #expect(MealTimeSlot.breakfast.greetingMessage == "Good morning! Logging Breakfast")
        #expect(MealTimeSlot.lunch.greetingMessage == "Midday boost! Logging Lunch")
        #expect(MealTimeSlot.dinner.greetingMessage == "Good evening! Logging Dinner")
        #expect(MealTimeSlot.snackLateNight.greetingMessage == "Late night bite! Logging Snack")
    }

    @Test func testDisplayNames() {
        #expect(MealTimeSlot.breakfast.displayName == "Breakfast")
        #expect(MealTimeSlot.lunch.displayName == "Lunch")
        #expect(MealTimeSlot.dinner.displayName == "Dinner")
        #expect(MealTimeSlot.snackLateNight.displayName == "Snack / Late Night")
    }

    @Test func testLookupByMealType() {
        #expect(MealTimeSlot.slot(forMealType: "Breakfast") == .breakfast)
        #expect(MealTimeSlot.slot(forMealType: "Lunch") == .lunch)
        #expect(MealTimeSlot.slot(forMealType: "Dinner") == .dinner)
        #expect(MealTimeSlot.slot(forMealType: "Snack / Late Night") == .snackLateNight)
        #expect(MealTimeSlot.slot(forMealType: "Snack") == .snackLateNight)
    }
}
