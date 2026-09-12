//
//  DashboardViewModelTests.swift
//  CallBiteTests
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//

@testable import CallBite
import Testing
import UIKit

@Suite("DashboardViewModel Food Analysis Tests")
struct DashboardViewModelTests {
    /// `analyzeCapturedPhoto`/`calculateManualNutrition` open the review card
    /// via `DispatchQueue.main.asyncAfter` (a deliberate 0.35s delay — see
    /// `openAddFoodCard` in DashboardViewModel.swift), not synchronously
    /// before the `await` returns. Tests that assert on `currentFood`/
    /// `isShowingAddFood` after a successful (non-warning) call must wait
    /// past that delay first.
    private func waitForCardOpenDelay() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    @Test("Analyzing a captured photo maps the FoodCandidate into the review card")
    @MainActor
    func analyzeCapturedPhotoMapsCandidateToFoodItem() async {
        let candidate = FoodCandidate(
            name: "Nasi Goreng with Fried Chicken",
            components: ["Fried Rice", "Fried Chicken", "Fried Egg"],
            nutrition: NutritionFacts(calories: 610, protein: 28, carbs: 70, fat: 18, fiber: 0),
            portionGrams: 350,
            foodProbability: 0.91
        )
        let analyzer = MockFoodAnalyzer(resultToReturn: candidate)
        let viewModel = DashboardViewModel(
            dailySummary: .sampleDashboard,
            foodAnalyzer: analyzer
        )

        await viewModel.analyzeCapturedPhoto(UIImage())
        await waitForCardOpenDelay()

        #expect(viewModel.currentFood.name == "Nasi Goreng with Fried Chicken")
        #expect(viewModel.currentFood.calories == 610)
        #expect(viewModel.currentFood.protein == 28)
        #expect(viewModel.currentFood.carbs == 70)
        #expect(viewModel.currentFood.fat == 18)
        #expect(viewModel.isShowingAddFood)
    }

    @Test("A generic analysis failure falls back to a placeholder food instead of dead-ending the flow")
    @MainActor
    func analyzeCapturedPhotoFallsBackOnGenericFailure() async {
        let analyzer = MockFoodAnalyzer(errorToThrow: .inferenceFailed("simulated failure"))
        let viewModel = DashboardViewModel(
            dailySummary: .sampleDashboard,
            foodAnalyzer: analyzer
        )

        await viewModel.analyzeCapturedPhoto(UIImage())
        await waitForCardOpenDelay()

        #expect(viewModel.currentFood.name == FoodItem.dimsumMentai.name)
        #expect(viewModel.isShowingAddFood)
        #expect(viewModel.nonFoodWarningMessage == nil)
    }

    @Test("A non-food detection shows a warning instead of opening the review card")
    @MainActor
    func analyzeCapturedPhotoWarnsOnNonFood() async {
        let analyzer = MockFoodAnalyzer(errorToThrow: .nonFoodDetected(probability: 0.12))
        let viewModel = DashboardViewModel(
            dailySummary: .sampleDashboard,
            foodAnalyzer: analyzer
        )
        let foodBeforeAnalysis = viewModel.currentFood

        await viewModel.analyzeCapturedPhoto(UIImage())

        #expect(viewModel.nonFoodWarningMessage != nil)
        #expect(!viewModel.isShowingAddFood)
        #expect(viewModel.currentFood == foodBeforeAnalysis)

        viewModel.dismissNonFoodWarning()
        #expect(viewModel.nonFoodWarningMessage == nil)
    }

    @Test("Manual calculation maps the estimated NutritionFacts into the review card")
    @MainActor
    func calculateManualNutritionMapsEstimateToFoodItem() async {
        let estimator = MockNutritionEstimator(
            resultToReturn: NutritionFacts(calories: 460, protein: 30, carbs: 40, fat: 15, fiber: 2)
        )
        let viewModel = DashboardViewModel(
            dailySummary: .sampleDashboard,
            nutritionEstimator: estimator
        )
        let ingredients = [
            ManualIngredientInput(ingredient: "Chicken Breast", portionGrams: "150", cookingMethod: "Grilled"),
            ManualIngredientInput(ingredient: "White Rice", portionGrams: "200", cookingMethod: "Steamed")
        ]

        await viewModel.calculateManualNutrition(name: "Grilled Chicken Rice Bowl", ingredients: ingredients)
        await waitForCardOpenDelay()

        #expect(viewModel.currentFood.name == "Grilled Chicken Rice Bowl")
        #expect(viewModel.currentFood.calories == 460)
        #expect(viewModel.currentFood.protein == 30)
        #expect(viewModel.currentFood.carbs == 40)
        #expect(viewModel.currentFood.fat == 15)
        #expect(viewModel.currentFood.fiber == 2)
        #expect(viewModel.isShowingAddFood)
    }

    @Test("A failed manual estimation falls back to the legacy gram-ratio math instead of dead-ending")
    @MainActor
    func calculateManualNutritionFallsBackOnFailure() async {
        let estimator = MockNutritionEstimator(errorToThrow: .modelNotFound("Foundation Models"))
        let viewModel = DashboardViewModel(
            dailySummary: .sampleDashboard,
            nutritionEstimator: estimator
        )
        let ingredients = [
            ManualIngredientInput(ingredient: "Tofu", portionGrams: "200", cookingMethod: "Fried")
        ]

        await viewModel.calculateManualNutrition(name: "Fried Tofu", ingredients: ingredients)
        await waitForCardOpenDelay()

        #expect(viewModel.currentFood.name == "Fried Tofu")
        // Legacy ratio math: 200g -> ratio 2.0 -> calories = 220 * 2.0 = 440
        #expect(viewModel.currentFood.calories == 440)
        #expect(viewModel.isShowingAddFood)
    }

    /// `analyzeCapturedPhoto`/`calculateManualNutrition` use their own 0.35s
    /// `DispatchQueue.main.asyncAfter` delay (see `waitForCardOpenDelay`
    /// above). `refreshCoachInsight`'s AI call has no such artificial delay —
    /// this just needs to outlast one real async round-trip through the mock.
    private func waitForInsightRefresh() async {
        try? await Task.sleep(nanoseconds: 200_000_000)
    }

    @Test("Coach insight starts as the rule-based fallback immediately, synchronously")
    @MainActor
    func coachInsightStartsAsFallbackImmediately() {
        let summary = DailySummary(targetCalories: 2000, consumedCalories: 1800)
        let viewModel = DashboardViewModel(
            dailySummary: summary,
            insightGenerator: MockInsightGenerator()
        )

        // No `await` here on purpose — this checks the value set synchronously
        // inside `init`, before the AI Task has any chance to run.
        #expect(viewModel.coachInsight == "Heads up! You have 200 kcal remaining.\n" +
            "Consider a lighter option for your next meal.")
    }

    @Test("Coach insight is replaced by the Foundation Model's text once generation succeeds")
    @MainActor
    func coachInsightUpdatesFromGenerator() async {
        let generator = MockInsightGenerator(resultToReturn: "Great protein intake today — keep it up!")
        let viewModel = DashboardViewModel(
            dailySummary: .sampleDashboard,
            insightGenerator: generator
        )

        await waitForInsightRefresh()

        #expect(viewModel.coachInsight == "Great protein intake today — keep it up!")
    }

    @Test("A failed insight generation leaves the rule-based fallback in place")
    @MainActor
    func coachInsightKeepsFallbackOnGeneratorFailure() async {
        let generator = MockInsightGenerator(errorToThrow: .modelNotFound("Foundation Models"))
        let summary = DailySummary(targetCalories: 2000, consumedCalories: 0)
        let viewModel = DashboardViewModel(
            dailySummary: summary,
            insightGenerator: generator
        )

        await waitForInsightRefresh()

        #expect(viewModel.coachInsight == "You have 2000 kcal remaining today.\n" +
            "You're on track — keep it balanced for your next meal.")
    }
}
