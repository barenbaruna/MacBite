//
//  GoalCalculatorTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

@testable import CallBite
import Testing

struct GoalCalculatorTests {
    @Test func testBMRCalculationPreferNotToSayMidpoint() {
        // PM specification: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 78
        let weight = 65.0
        let height = 170.0
        let age = 25
        let sex = BiologicalSex.preferNotToSay

        #expect(sex.bmrConstant == -78.0)
        #expect(BiologicalSex.other == .preferNotToSay)
        #expect(sex.displayName == "Prefer not to say")

        let expectedBMR = (10.0 * 65.0) + (6.25 * 170.0) - (5.0 * 25.0) - 78.0
        #expect(expectedBMR == 1509.5)

        let calculatedBMR = GoalCalculator.calculateBMR(
            weightKg: weight,
            heightCm: height,
            age: age,
            sex: sex
        )
        #expect(calculatedBMR == 1509.5)
    }

    @Test func testBMRCalculationMaleAndFemaleConstants() {
        let weight = 70.0
        let height = 175.0
        let age = 25

        // Male constant: +5
        let maleBMR = GoalCalculator.calculateBMR(weightKg: weight, heightCm: height, age: age, sex: .male)
        let expectedMale = (10.0 * 70.0) + (6.25 * 175.0) - (5.0 * 25.0) + 5.0
        #expect(maleBMR == expectedMale)
        #expect(BiologicalSex.male.bmrConstant == 5.0)

        // Female constant: -161
        let femaleBMR = GoalCalculator.calculateBMR(weightKg: weight, heightCm: height, age: age, sex: .female)
        let expectedFemale = (10.0 * 70.0) + (6.25 * 175.0) - (5.0 * 25.0) - 161.0
        #expect(femaleBMR == expectedFemale)
        #expect(BiologicalSex.female.bmrConstant == -161.0)
    }

    @Test func testTDEEAndNutritionGoalCalculation() {
        let bmr = 1500.0
        let tdee = GoalCalculator.calculateTDEE(bmr: bmr, activityLevel: .lightlyActive)
        #expect(tdee == 1500.0 * 1.375)

        let cutTarget = GoalCalculator.calculateDailyCalorieTarget(tdee: tdee, category: .cutting)
        #expect(cutTarget == Int((tdee - 500.0).rounded()))

        let maintainTarget = GoalCalculator.calculateDailyCalorieTarget(tdee: tdee, category: .maintaining)
        #expect(maintainTarget == Int(tdee.rounded()))

        let bulkTarget = GoalCalculator.calculateDailyCalorieTarget(tdee: tdee, category: .bulking)
        #expect(bulkTarget == Int((tdee + 300.0).rounded()))

        let macros = GoalCalculator.calculateMacronutrients(dailyCalories: 2000)
        #expect(macros.targetCalories == 2000)
        #expect(macros.targetCarbsGrams == 225)
        #expect(macros.targetProteinGrams == 125)
        #expect(macros.targetFatGrams == 67)
        #expect(macros.targetFiberGrams == 28)
    }

    @Test func testGoalCalculatorWithProfile() {
        let profile = UserHealthProfile(
            age: 30,
            biologicalSex: .preferNotToSay,
            weightKg: 68.0,
            heightCm: 172.0
        )
        let bmr = GoalCalculator.calculateBMR(profile: profile)
        let expected = (10.0 * 68.0) + (6.25 * 172.0) - (5.0 * 30.0) - 78.0
        #expect(bmr == expected)
    }
}
