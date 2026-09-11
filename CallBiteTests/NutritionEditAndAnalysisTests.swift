//
//  NutritionEditAndAnalysisTests.swift
//  CallBiteTests
//
//  Created by Codex on 11/09/26.
//

@testable import CallBite
import Foundation
import Testing

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
    @Test func testCoreMLFoodAnalyzerDefaultPhoto() async throws {
        let analyzer = CoreMLFoodAnalyzer()
        let food = try await analyzer.analyzePhoto(imageData: Data())
        #expect(food.name == "Scanned Food")
        #expect(food.calories == 475)
        #expect(food.fiber == 4)
    }

    @Test func testGeminiFoodAnalyzerManualCalculation() async throws {
        let analyzer = GeminiFoodAnalyzer()
        let ingredients = [
            IngredientDescriptor(name: "Chicken Breast", portionGrams: 150.0),
            IngredientDescriptor(name: "Brown Rice", portionGrams: 100.0)
        ]
        let food = try await analyzer.analyzeManual(name: "Chicken & Rice", ingredients: ingredients)
        #expect(food.name == "Chicken & Rice")
        #expect(food.calories > 0)
        #expect(food.protein > 0)
    }

    @Test func testMockFoodAnalyzer() async throws {
        let mock = MockFoodAnalyzer(
            stubbedPhotoFood: .chickenRiceBowl,
            stubbedManualFood: .oatmealBerry
        )
        let photoFood = try await mock.analyzePhoto(imageData: Data())
        #expect(photoFood.name == FoodItem.chickenRiceBowl.name)

        let manualFood = try await mock.analyzeManual(name: "Custom Oatmeal", ingredients: [])
        #expect(manualFood.name == "Custom Oatmeal")
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
