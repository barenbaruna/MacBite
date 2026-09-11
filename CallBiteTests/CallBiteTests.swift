//
//  CallBiteTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

@testable import CallBite
import HealthKit
import Testing

struct CallBiteTests {

    @Test func testHealthyWeightRange() async throws {
        let range = ScientificWeightEngine.healthyWeightRange(heightCm: 170.0)
        // 170cm -> 1.7m -> 1.7^2 = 2.89. 18.5 * 2.89 = 53.465, 24.9 * 2.89 = 71.961
        #expect(range.lowerBound > 53.0 && range.lowerBound < 54.0)
        #expect(range.upperBound > 71.5 && range.upperBound < 72.5)
    }

    @Test func testWeightEvaluationCutting() async throws {
        let insight = ScientificWeightEngine.evaluate(
            currentWeightKg: 70.0,
            targetWeightKg: 65.0,
            heightCm: 170.0
        )
        #expect(insight.category == .cutting)
        #expect(insight.deltaKg == -5.0)
        #expect(insight.isSafeWHO)
        #expect(insight.estimatedWeeks == 10)
        #expect(insight.dailyCalorieAdjustment == -500.0)
    }

    @Test func testWeightEvaluationBulking() async throws {
        let insight = ScientificWeightEngine.evaluate(
            currentWeightKg: 60.0,
            targetWeightKg: 65.0,
            heightCm: 175.0
        )
        #expect(insight.category == .bulking)
        #expect(insight.deltaKg == 5.0)
        #expect(insight.isSafeWHO)
        #expect(insight.dailyCalorieAdjustment == 300.0)
    }

    @Test func testWeightEvaluationMaintaining() async throws {
        let insight = ScientificWeightEngine.evaluate(
            currentWeightKg: 60.0,
            targetWeightKg: 60.0,
            heightCm: 170.0
        )
        #expect(insight.category == .maintaining)
        #expect(insight.deltaKg == 0.0)
        #expect(insight.isSafeWHO)
        #expect(insight.dailyCalorieAdjustment == 0.0)
    }

    @Test func testRecommendedInitialTarget() async throws {
        // Healthy BMI (60kg at 168cm -> BMI 21.3) should default to currentWeight
        let normalTarget = ScientificWeightEngine.recommendedInitialTarget(currentWeightKg: 60.0, heightCm: 168.0)
        #expect(normalTarget == 60.0)

        // Overweight (85kg at 168cm -> healthy max ~70.3kg) should default to healthy upper bound
        let overTarget = ScientificWeightEngine.recommendedInitialTarget(currentWeightKg: 85.0, heightCm: 168.0)
        #expect(overTarget <= 70.5 && overTarget >= 70.0)

        // Underweight (45kg at 168cm -> healthy min ~52.2kg) should default to healthy lower bound
        let underTarget = ScientificWeightEngine.recommendedInitialTarget(currentWeightKg: 45.0, heightCm: 168.0)
        #expect(underTarget >= 52.0 && underTarget <= 52.5)
    }

    @Test func testWeightGoalViewModel() async throws {
        let vm = WeightGoalViewModel(currentWeightKg: 60.0, targetWeightKg: 56.0, heightCm: 162.0)
        #expect(vm.activeCategory == .cutting)
        #expect(abs(vm.targetWeightKg - 56.0) < 0.01)

        vm.targetWeightKg = 64.0
        #expect(vm.activeCategory == .bulking)
        #expect(vm.targetWeightKg == 64.0)

        // Test default nil targetWeightKg
        let vmDefault = WeightGoalViewModel(currentWeightKg: 60.0, targetWeightKg: nil, heightCm: 168.0)
        #expect(vmDefault.targetWeightKg == 60.0)
        #expect(vmDefault.activeCategory == .maintaining)
    }

    @Test func testWeightGoalDismissButtonDefault() throws {
        let defaultView = WeightGoalView(currentWeightKg: 60.0, targetWeightKg: 56.0, heightCm: 168.0)
        #expect(!defaultView.showsDismissButton)

        let sheetView = WeightGoalView(
            currentWeightKg: 60.0,
            targetWeightKg: 56.0,
            heightCm: 168.0,
            showsDismissButton: true
        )
        #expect(sheetView.showsDismissButton)
    }

    @Test @MainActor func testOnboardingViewModelTransitions() async throws {
        let mockHealth = MockHealthKitService()
        let vm = OnboardingViewModel(healthKitService: mockHealth, initialStep: .healthPrompt)

        #expect(vm.currentStep == .healthPrompt)
        #expect(!vm.isHealthAccessGranted)

        await vm.connectToHealth()

        #expect(vm.isHealthAccessGranted)
        #expect(vm.healthProfile.weightKg == 56.0)
        #expect(vm.currentStep == .lifestyle)

        vm.selectActivity(.moderatelyActive)
        #expect(vm.selectedActivity == .moderatelyActive)
        #expect(vm.canProceedFromLifestyle)

        vm.completeOnboarding(onFinish: {})
        #expect(vm.currentStep == .targetGoal)
    }

    @Test func testDailySummaryCalculations() async throws {
        let summary = DailySummary(
            dateString: "Today, 4 Sep 2026",
            targetCalories: 2654,
            consumedCalories: 1484,
            totalCarbs: 1170,
            totalProtein: 1170,
            totalFat: 1170,
            totalFiber: 1170,
            streakDays: 3
        )
        #expect(summary.remainingCalories == 1170)
        #expect(abs(summary.progressRatio - (1484.0 / 2654.0)) < 0.001)
    }

    @Test @MainActor func testDashboardViewModelFoodLogging() async throws {
        let initialSummary = DailySummary(
            targetCalories: 2400,
            consumedCalories: 1000
        )
        let vm = DashboardViewModel(dailySummary: initialSummary, initialFood: .dimsumMentai)

        #expect(vm.phase == .idle)
        #expect(!vm.isShowingAddFood)

        vm.resetAndOpenAddFood(with: .chickenRiceBowl)
        #expect(vm.isShowingAddFood)
        #expect(vm.currentFood.name == "Grilled Chicken Bowl")
        #expect(vm.phase == .idle)

        vm.startSaveAnimation(reduceMotion: true)
        #expect(vm.phase == .completed)
        #expect(!vm.isShowingAddFood)
        #expect(vm.dailySummary.consumedCalories == 1000 + 680)
    }

    @Test func testHealthKitClientAvailabilityAndTypes() async throws {
        let isAvailable = HKHealthStore.isHealthDataAvailable()
        #expect(isAvailable || !isAvailable)
        #expect(!HealthKitClient.shareTypes.isEmpty)
        #expect(!HealthKitClient.readTypes.isEmpty)
    }

    @Test @MainActor func testOnboardingHealthKitAllowedSkipsPersonalize() async throws {
        let mockService = MockHealthKitService(
            shouldGrantAccess: true,
            mockProfile: UserHealthProfile(age: 26, biologicalSex: .male, weightKg: 75.0, heightCm: 180.0)
        )
        let vm = OnboardingViewModel(healthKitService: mockService, initialStep: .healthPrompt)

        #expect(vm.currentStep == .healthPrompt)
        await vm.connectToHealth()

        // HealthKit has data -> skips personalize, goes straight to lifestyle!
        #expect(vm.currentStep == .lifestyle)
        #expect(vm.isHealthAccessGranted)
        #expect(vm.healthProfile.age == 26)
        #expect(vm.healthProfile.weightKg == 75.0)
    }

    @Test @MainActor func testOnboardingHealthKitDeniedShowsPersonalize() async throws {
        let mockService = MockHealthKitService(
            shouldGrantAccess: false,
            mockProfile: .empty
        )
        let vm = OnboardingViewModel(healthKitService: mockService, initialStep: .healthPrompt)

        #expect(vm.currentStep == .healthPrompt)
        await vm.connectToHealth()

        // HealthKit access denied -> must show manual Personalize screen!
        #expect(vm.currentStep == .personalize)
        #expect(!vm.isHealthAccessGranted)

        // User fills in manual profile
        let birthDate = Calendar.current.date(from: DateComponents(year: 1996, month: 9, day: 15)) ?? Date()
        vm.saveManualProfile(dateOfBirth: birthDate, sex: .other, heightCm: 183.0, weightKg: 108.0)

        #expect(vm.currentStep == .lifestyle)
        #expect(vm.healthProfile.biologicalSex == .other)
        #expect(vm.healthProfile.heightCm == 183.0)
        #expect(vm.healthProfile.weightKg == 108.0)
    }

    @Test @MainActor func testOnboardingManualSetupOption() async throws {
        let vm = OnboardingViewModel(initialStep: .healthPrompt)

        vm.enterManually()
        #expect(vm.currentStep == .personalize)

        vm.cancelPersonalize()
        #expect(vm.currentStep == .healthPrompt)
    }

    @Test @MainActor func testOnboardingBackNavigationFlow() async throws {
        let vm = OnboardingViewModel(initialStep: .healthPrompt)

        // Health Prompt -> Enter Manually -> Personalize
        vm.enterManually()
        #expect(vm.currentStep == .personalize)

        // Back from Personalize -> Health Prompt
        vm.cancelPersonalize()
        #expect(vm.currentStep == .healthPrompt)

        // Save manual profile with direct age (matches new custom design)
        vm.enterManually()
        vm.saveManualProfile(age: 22, sex: .male, heightCm: 162.0, weightKg: 56.0)
        #expect(vm.currentStep == .lifestyle)
        #expect(vm.healthProfile.age == 22)
        #expect(vm.healthProfile.biologicalSex == .male)
        #expect(vm.healthProfile.weightKg == 56.0)
        #expect(vm.healthProfile.heightCm == 162.0)

        // Back from Lifestyle -> Personalize (because health was not granted)
        vm.goBackFromLifestyle()
        #expect(vm.currentStep == .personalize)

        // Advance to Lifestyle -> Select activity -> Complete onboarding to Target Goal
        vm.nextFromPersonalize()
        vm.selectActivity(.moderatelyActive)
        vm.completeOnboarding(onFinish: {})
        #expect(vm.currentStep == .targetGoal)

        // Back from Target Goal -> Lifestyle
        vm.goBackFromTargetGoal()
        #expect(vm.currentStep == .lifestyle)
    }

    @Test @MainActor func testOnboardingBackFromLifestyleWhenHealthGranted() async throws {
        let mockService = MockHealthKitService(
            shouldGrantAccess: true,
            mockProfile: UserHealthProfile(age: 25, biologicalSex: .female, weightKg: 62.0, heightCm: 170.0)
        )
        let vm = OnboardingViewModel(healthKitService: mockService, initialStep: .healthPrompt)

        await vm.connectToHealth()
        #expect(vm.currentStep == .lifestyle)
        #expect(vm.isHealthAccessGranted)

        // Back from Lifestyle when health granted -> Health Prompt
        vm.goBackFromLifestyle()
        #expect(vm.currentStep == .healthPrompt)
    }

    @Test func testDesignSystemModalCardTokens() {
        #expect(AppCornerRadius.modalCard == 42)
        #expect(AppMetrics.modalCardMaxWidth == 360)
        #expect(AppMetrics.modalCardMaxHeight == 620)
        #expect(AppMetrics.modalCardHeightRatio == 0.74)
        #expect(AppMetrics.modalCardShadowRadius == 28)
        #expect(AppMetrics.primaryButtonHeight == 50)
        #expect(AppMetrics.energyDropletSize == 28)
    }

    @Test func testBiologicalSexSelectableCases() {
        #expect(!BiologicalSex.selectableCases.contains(.notSet))
        #expect(BiologicalSex.selectableCases.contains(.female))
        #expect(BiologicalSex.selectableCases.contains(.male))
        #expect(BiologicalSex.selectableCases.contains(.other))
    }

    @Test @MainActor func testOnboardingHealthKitMissingBiologicalSexRoutesToPersonalize() async throws {
        let mockService = MockHealthKitService(
            shouldGrantAccess: true,
            mockProfile: UserHealthProfile(age: 24, biologicalSex: .notSet, weightKg: 65.0, heightCm: 172.0)
        )
        let vm = OnboardingViewModel(healthKitService: mockService, initialStep: .healthPrompt)

        await vm.connectToHealth()
        #expect(vm.currentStep == .personalize)
        #expect(!vm.isHealthAccessGranted)
    }

    @Test @MainActor func testProfileViewModelStateAndSave() {
        var savedProfile: UserHealthProfile?
        let initial = UserHealthProfile(age: 22, biologicalSex: .male, weightKg: 56.0, heightCm: 162.0)
        let vm = ProfileViewModel(initialProfile: initial) { profile in
            savedProfile = profile
        }

        #expect(vm.age == 22)
        #expect(vm.biologicalSex == .male)
        #expect(vm.weightKg == 56.0)
        #expect(vm.heightCm == 162.0)
        #expect(!vm.isShowingChangeGoal)
        #expect(vm.activeFieldForEdit == nil)
        #expect(vm.targetWeightKg == nil)

        vm.age = 23
        vm.weightKg = 58.0
        vm.updateGoal(targetWeight: 54.0, category: .cutting)
        #expect(vm.targetWeightKg == 54.0)
        #expect(vm.goalCategory == .cutting)
        #expect(vm.goalSummaryText == "Lose Weight (54kg)")

        vm.saveProfile()

        #expect(savedProfile?.age == 23)
        #expect(savedProfile?.weightKg == 58.0)
        #expect(savedProfile?.targetWeightKg == 54.0)
        #expect(savedProfile?.goalCategory == .cutting)
    }
}

@Suite("FoodLoggingTests")
struct FoodLoggingTests {
    @Test func testNutritionEditFieldProperties() {
        #expect(NutritionEditField.calories.unit == "kcal")
        #expect(NutritionEditField.protein.unit == "g")
        #expect(NutritionEditField.carbs.unit == "g")
        #expect(NutritionEditField.fat.unit == "g")

        #expect(NutritionEditField.calories.step == 10)
        #expect(NutritionEditField.protein.step == 1)

        #expect(NutritionEditField.calories.quickAddAmounts == [10, 50, 100])
        #expect(NutritionEditField.protein.quickAddAmounts == [1, 5, 10])
    }

    @Test func testFoodItemManualMacroMutation() {
        var food = FoodItem.dimsumMentai
        #expect(food.calories == 475)
        #expect(food.protein == 14)
        #expect(food.carbs == 81)
        #expect(food.fat == 12)

        food.calories = 520
        food.protein = 20
        food.carbs = 70
        food.fat = 15

        #expect(food.calories == 520)
        #expect(food.protein == 20)
        #expect(food.carbs == 70)
        #expect(food.fat == 15)
    }

    @Test @MainActor func testDashboardResetAndOpenAddFood() {
        let vm = DashboardViewModel()
        #expect(!vm.isShowingAddFood)

        let customFood = FoodItem(
            name: "Nasi Padang",
            mealType: "Lunch",
            dateString: "10 September 2026",
            calories: 650,
            protein: 35,
            carbs: 70,
            fat: 25,
            fiber: 3
        )
        vm.resetAndOpenAddFood(with: customFood)

        #expect(vm.isShowingAddFood)
        #expect(vm.currentFood.name == "Nasi Padang")
        #expect(vm.currentFood.calories == 650)
        #expect(vm.flipAngle == 0.0)
        #expect(!vm.isCardCompressed)
    }
}
