//
//  ScientificWeightEngineTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

@testable import CallBite
import Testing

@Suite("ScientificWeightEngine Tests")
struct ScientificWeightEngineTests {

    @Test("User profile 182cm, 69kg male age 23 has 61-82kg healthy range and recommended target 69kg")
    func testUserProfile69kg182cm() {
        let height = 182.0
        let currentWeight = 69.0
        let age = 23

        // WHO healthy BMI 18.5 - 24.9
        let range = ScientificWeightEngine.healthyWeightRange(heightCm: height)
        #expect(range.lowerBound >= 61.0 && range.lowerBound <= 61.5)
        #expect(range.upperBound >= 82.0 && range.upperBound <= 82.6)

        // 69kg is within healthy range -> recommended initial target is 69.0 (Maintain)
        let recommended = ScientificWeightEngine.recommendedInitialTarget(
            currentWeightKg: currentWeight,
            heightCm: height
        )
        #expect(recommended == 69.0)

        // Slider range must comfortably accommodate Zone 1, 2, and 3
        let sliderRange = ScientificWeightEngine.sliderRange(currentWeightKg: currentWeight, heightCm: height)
        #expect(sliderRange.lowerBound <= 40.0)
        #expect(sliderRange.upperBound >= 95.0)

        // ViewModel test
        let vm = WeightGoalViewModel(currentWeightKg: currentWeight, heightCm: height)
        #expect(vm.targetWeightKg == 69.0)
        #expect(vm.activeCategory == .maintaining)
        #expect(vm.minSliderWeight <= 40.0)
        #expect(vm.maxSliderWeight >= 95.0)

        // BMR: 10*69 + 6.25*182 - 5*23 + 5 = 690 + 1137.5 - 115 + 5 = 1717.5 kcal
        let bmr = GoalCalculator.calculateBMR(weightKg: currentWeight, heightCm: height, age: age, sex: .male)
        #expect(bmr == 1717.5)
    }

    @Test("Test profile 195cm, 99kg male age 29 has 70-95kg healthy range and dynamic slider extends past 99kg")
    func testTallOverweightProfile99kg195cm() {
        let height = 195.0
        let currentWeight = 99.0
        let age = 29

        // WHO healthy BMI 18.5 - 24.9 -> ~70.3 to ~94.7 kg
        let range = ScientificWeightEngine.healthyWeightRange(heightCm: height)
        #expect(range.lowerBound >= 70.0 && range.lowerBound <= 70.5)
        #expect(range.upperBound >= 94.5 && range.upperBound <= 95.0)

        // 99kg is overweight by 4.3kg (within 15kg of boundary) -> targets healthy upper bound ~94.5kg (Cutting)
        let recommended = ScientificWeightEngine.recommendedInitialTarget(
            currentWeightKg: currentWeight,
            heightCm: height
        )
        #expect(recommended >= 94.0 && recommended <= 95.0)

        // Dynamic slider range MUST extend well beyond 99kg (at least 99 + 15 = 114kg)
        let sliderRange = ScientificWeightEngine.sliderRange(currentWeightKg: currentWeight, heightCm: height)
        #expect(sliderRange.upperBound >= 114.0)
        #expect(sliderRange.contains(99.0))
        #expect(sliderRange.contains(105.0)) // Bulking room

        // ViewModel must not cap at 90kg anymore
        let vm = WeightGoalViewModel(currentWeightKg: currentWeight, heightCm: height)
        #expect(vm.maxSliderWeight >= 114.0)
        #expect(vm.minSliderWeight <= 40.0)
        #expect(vm.activeCategory == .cutting)

        // BMR: 10*99 + 6.25*195 - 5*29 + 5 = 990 + 1218.75 - 145 + 5 = 2068.75 kcal
        let bmr = GoalCalculator.calculateBMR(weightKg: currentWeight, heightCm: height, age: age, sex: .male)
        #expect(bmr == 2068.75)

        // TDEE Moderately Active (1.55x) -> 3206.56 kcal
        let tdee = GoalCalculator.calculateTDEE(bmr: bmr, activityLevel: .moderatelyActive)
        #expect(Int(tdee.rounded()) == 3207)

        // Cutting target (-500 kcal) -> 2707 kcal
        let targetCalories = GoalCalculator.calculateDailyCalorieTarget(tdee: tdee, category: .cutting)
        #expect(targetCalories == 2707)
    }

    @Test("Significantly overweight profile defaults to 10% clinical milestone")
    func testClinicalMilestoneForSevereOverweight() {
        // 175cm, 130kg (healthy upper bound is ~76.3kg, difference is > 15kg)
        let height = 175.0
        let currentWeight = 130.0

        let recommended = ScientificWeightEngine.recommendedInitialTarget(
            currentWeightKg: currentWeight,
            heightCm: height
        )
        // 10% loss of 130kg = 13kg loss -> 117.0kg milestone target
        #expect(recommended == 117.0)

        let sliderRange = ScientificWeightEngine.sliderRange(currentWeightKg: currentWeight, heightCm: height)
        #expect(sliderRange.upperBound >= 145.0)
        #expect(sliderRange.contains(130.0))
    }
}
