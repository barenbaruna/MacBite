//
//  DashboardViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Combine
import SwiftUI
import UIKit

/// State machine for the fluid food saving animation phases.
public enum SaveAnimationPhase: Equatable, Sendable {
    case idle
    case compressingAndFlipping
    case readingConfirmed
    case morphingAndFlowing
    case orbitingAndLoading
    case dissolvingOrb
    case completed
}

/// Spring physics configuration for Apple HIG-aligned fluid animations.
public enum MotionConfig {
    public static let compressDuration: Double = 0.65
    public static let readingPause: UInt64 = 600_000_000
    public static let morphDuration: Double = 0.58
    public static let progressDuration: Double = 0.85
    public static let dissolveDuration: Double = 0.40
    public static let ringBounceDuration: Double = 0.38

    public static let compressFlipSpring: Animation = .spring(response: 0.52, dampingFraction: 0.82)
    public static let morphTravelSpring: Animation = .spring(response: 0.55, dampingFraction: 0.85)
    public static let progressSpring: Animation = .spring(response: 0.82, dampingFraction: 0.86)
    public static let dissolveEase: Animation = .easeOut(duration: dissolveDuration)
    public static let ringBounceSpring: Animation = .spring(response: 0.38, dampingFraction: 0.70)
}

/// ViewModel managing daily nutrition summaries and orchestrating the fluid food save sequence.
@MainActor
public final class DashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public var dailySummary: DailySummary
    @Published public var currentFood: FoodItem
    @Published public var phase: SaveAnimationPhase = .idle
    @Published public var isShowingAddFood: Bool = false
    @Published public var isCardCompressed: Bool = false
    @Published public var isShowingWeightGoal: Bool = false
    @Published public var isShowingProfile: Bool = false
    @Published public var isShowingLoggingOptions: Bool = false

    // Card & Flow Motion Properties
    @Published public var flipAngle: Double = 0.0
    @Published public var morphProgress: CGFloat = 0.0
    @Published public var cardContentOpacity: Double = 1.0
    @Published public var orbGlowOpacity: Double = 0.0
    @Published public var orbScale: CGFloat = 1.0
    @Published public var orbBlur: CGFloat = 0.0
    @Published public var cardOffsetX: CGFloat = 0.0
    @Published public var cardOffsetY: CGFloat = 0.0

    // Ring Geometry & Progress
    @Published public var ringGeometry: RingGeometry = RingGeometry()
    @Published public var rippleScale: CGFloat = 0.5
    @Published public var rippleOpacity: Double = 0.0
    @Published public var ringProgress: CGFloat = 0.56
    @Published public var orbProgress: Double = 0.56
    @Published public var ringScale: CGFloat = 1.0

    // Sensory Feedback Triggers
    @Published public var triggerTapHaptic: Bool = false
    @Published public var triggerSuccessHaptic: Bool = false

    // AI Analysis Feedback
    /// Set when `analyzeCapturedPhoto` detects the photo isn't food. The review
    /// card is NOT opened in that case — the View should present this as an
    /// alert instead, so a non-food result never looks like a real logged meal.
    @Published public var nonFoodWarningMessage: String?

    // MARK: - Dependencies

    // Default-valued (rather than a required constructor param) so every
    // existing `DashboardViewModel()` / `DashboardViewModel(dailySummary:...)`
    // call site (ContentView's test harnesses, DashboardFactory) keeps
    // compiling unchanged, while still being overridable for tests/previews
    // (e.g. `DashboardViewModel(foodAnalyzer: MockFoodAnalyzer())`).
    private let foodAnalyzer: FoodAnalyzing
    private let nutritionEstimator: NutritionEstimating

    // MARK: - Initialization

    public init(
        foodAnalyzer: FoodAnalyzing = CoreMLFoodAnalyzer(),
        nutritionEstimator: NutritionEstimating = FoundationModelNutritionEstimator()
    ) {
        let defaultSummary = DailySummary.sampleDashboard
        self.dailySummary = defaultSummary
        self.currentFood = FoodItem.dimsumMentai
        self.foodAnalyzer = foodAnalyzer
        self.nutritionEstimator = nutritionEstimator
        let currentRatio = CGFloat(defaultSummary.progressRatio)
        self.ringProgress = currentRatio
        self.orbProgress = Double(currentRatio)
        #if DEBUG
        print("[DashboardViewModel] init (default) -> \(ObjectIdentifier(self))")
        #endif
    }

    public init(
        dailySummary: DailySummary,
        initialFood: FoodItem? = nil,
        foodAnalyzer: FoodAnalyzing = CoreMLFoodAnalyzer(),
        nutritionEstimator: NutritionEstimating = FoundationModelNutritionEstimator()
    ) {
        self.dailySummary = dailySummary
        self.currentFood = initialFood ?? FoodItem.dimsumMentai
        self.foodAnalyzer = foodAnalyzer
        self.nutritionEstimator = nutritionEstimator
        let currentRatio = CGFloat(dailySummary.progressRatio)
        self.ringProgress = currentRatio
        self.orbProgress = Double(currentRatio)
        #if DEBUG
        print("[DashboardViewModel] init (dailySummary:) -> \(ObjectIdentifier(self))")
        #endif
    }

    // MARK: - Public Animation Methods

    public func startSaveAnimation(
        reduceMotion: Bool = false,
        screenWidth: CGFloat = 393,
        containerCenterY: CGFloat = 426
    ) {
        guard phase == .idle else { return }
        triggerTapHaptic.toggle()

        if reduceMotion {
            executeReduceMotionFallback()
            return
        }

        phase = .compressingAndFlipping
        withAnimation(MotionConfig.compressFlipSpring) {
            isCardCompressed = true
            flipAngle = 180.0
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(MotionConfig.compressDuration * 1_000_000_000))
            await phaseHoldConfirmation(screenWidth: screenWidth, containerCenterY: containerCenterY)
        }
    }

    public func resetAndOpenAddFood() {
        resetAndOpenAddFood(with: FoodItem.dimsumMentai)
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

    // MARK: - AI Nutrition Analysis

    /// Analyzes a captured/picked food photo via `foodAnalyzer` and opens the
    /// review card with the result. A non-food photo shows `nonFoodWarningMessage`
    /// instead (see the alert in `DashboardView`) and never opens the review
    /// card. Other failures (model unavailable, inference error) still fall
    /// back to a placeholder food so the flow doesn't dead-end.
    public func analyzeCapturedPhoto(_ image: UIImage) async {
        do {
            let candidate = try await foodAnalyzer.analyze(image)
            openAddFoodCard(with: mapToFoodItem(candidate, photo: image))
        } catch AppError.nonFoodDetected(let probability) {
            // Do NOT open the review card here — a non-food photo must never
            // look like a successfully logged meal (that was the previous bug:
            // it silently fell back to a "Dimsum Mentai" placeholder that was
            // indistinguishable from a real result).
            let percent = Int((probability * 100).rounded())
            nonFoodWarningMessage = "This photo wasn't detected as food (\(percent)% confidence). " +
                "Please retake the photo with the food clearly visible."
        } catch {
            // Other failures (model unavailable, inference error) still fall
            // back to a placeholder food so the flow doesn't dead-end — but at
            // least the real photo is attached instead of a stock icon.
            var fallback = FoodItem.dimsumMentai
            fallback.photoData = image.jpegData(compressionQuality: 0.8)
            openAddFoodCard(with: fallback)
        }
    }

    public func dismissNonFoodWarning() {
        nonFoodWarningMessage = nil
    }

    /// Estimates nutrition for a manually-typed meal via `nutritionEstimator`
    /// and opens the review card. Falls back to `legacyRatioEstimate` (the
    /// simple gram-ratio math this app used before AI estimation existed) if
    /// the estimator is unavailable or fails — manual entries always have a
    /// name and portions the user typed, so unlike photos there's no "not
    /// food" case to warn about; any failure just degrades to that fallback.
    ///
    /// Not `public` (unlike this file's other methods) because its parameter,
    /// `ManualIngredientInput`, is an internal-access type owned by
    /// `Features/ManualLogging/Models/` — deliberately not touched here (see
    /// implementation plan). `internal` is sufficient since the only caller,
    /// `DashboardView+Subviews.swift`, is in the same module.
    func calculateManualNutrition(name: String, ingredients: [ManualIngredientInput]) async {
        let meal = mapToMealDescription(name: name, ingredients: ingredients)

        #if DEBUG
        print("[ManualNutrition] called on \(ObjectIdentifier(self)) with name=\"\(name)\" rawIngredientCount=\(ingredients.count)")
        print("[ManualNutrition] mapped meal: foodName=\"\(meal.foodName)\" ingredients=\(meal.ingredients.map { "\($0.name)/\($0.portionGrams ?? -1)g/\($0.cookingMethod ?? "-")" })")
        #endif

        do {
            let nutrition = try await nutritionEstimator.estimate(meal)
            #if DEBUG
            print("[ManualNutrition] Foundation Model SUCCESS -> \(nutrition)")
            #endif
            openAddFoodCard(with: mapToFoodItem(name: meal.foodName, nutrition: nutrition))
        } catch {
            #if DEBUG
            print("[ManualNutrition] Foundation Model FAILED: \(error). Falling back to legacy ratio math.")
            #endif
            openAddFoodCard(with: legacyRatioEstimate(name: name, ingredients: ingredients))
        }
    }

    /// Opens the review card after a short delay, dispatched as a fresh main-
    /// queue turn (NOT `Task.sleep` inside the same async context — that was
    /// tried first and did not reliably show the card). `presentedSheetRoute`/
    /// `presentedFullScreenRoute` in `DashboardView+Subviews.swift` are cleared
    /// synchronously right before this is called; `morphingCardOverlay` is a
    /// hand-rolled `if`-conditioned ZStack overlay (not a real `.sheet`), and
    /// mutating its driving `@Published` state too soon — or from a resumed
    /// `Task` — can get coalesced into the sheet/fullScreenCover's own dismiss
    /// transaction and silently never render. `DispatchQueue.main.asyncAfter`
    /// guarantees a genuinely separate run-loop turn, which is the same fix
    /// this codebase already used for manual logging before AI estimation
    /// existed (see git history of `handleManualCalculation`) — restored here
    /// instead of reinventing a new (and, in practice, unreliable) approach.
    private func openAddFoodCard(with food: FoodItem) {
        #if DEBUG
        print("[ManualNutrition] openAddFoodCard scheduled on \(ObjectIdentifier(self))")
        #endif
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self else {
                #if DEBUG
                print("[ManualNutrition] openAddFoodCard fired but self was DEALLOCATED — card cannot open.")
                #endif
                return
            }
            #if DEBUG
            print("[ManualNutrition] openAddFoodCard firing on \(ObjectIdentifier(self)), setting isShowingAddFood=true")
            #endif
            self.resetAndOpenAddFood(with: food)
        }
    }

    // MARK: - Internal Animation Sequence

    private func phaseHoldConfirmation(screenWidth: CGFloat, containerCenterY: CGFloat) async {
        phase = .readingConfirmed
        try? await Task.sleep(nanoseconds: MotionConfig.readingPause)
        await phaseMorphToLightAndFlow(screenWidth: screenWidth, containerCenterY: containerCenterY)
    }

    private func phaseMorphToLightAndFlow(screenWidth: CGFloat, containerCenterY: CGFloat) async {
        phase = .morphingAndFlowing

        withAnimation(.easeInOut(duration: 0.20)) {
            cardContentOpacity = 0.0
            orbGlowOpacity = 1.0
            orbScale = 1.0
            orbBlur = 0.0
        }

        // Target entry point on progress ring matching current fill percentage
        let entryPoint = ringGeometry.point(forProgress: Double(ringProgress))
        let targetOffsetY = entryPoint.y - containerCenterY
        let targetOffsetX = entryPoint.x - (screenWidth / 2.0)

        withAnimation(MotionConfig.morphTravelSpring) {
            morphProgress = 1.0
            cardOffsetY = targetOffsetY
            cardOffsetX = targetOffsetX
        }

        try? await Task.sleep(nanoseconds: UInt64(MotionConfig.morphDuration * 1_000_000_000))
        await phaseStartOrbitAndFillProgress()
    }

    private func phaseStartOrbitAndFillProgress() async {
        phase = .orbitingAndLoading
        orbProgress = Double(ringProgress)

        let newConsumed = dailySummary.consumedCalories + currentFood.calories
        dailySummary.consumedCalories = newConsumed
        let targetRatio = CGFloat(newConsumed) / CGFloat(max(1, dailySummary.targetCalories))

        withAnimation(MotionConfig.progressSpring) {
            ringProgress = targetRatio
            orbProgress = Double(targetRatio)
        }

        try? await Task.sleep(nanoseconds: UInt64(MotionConfig.progressDuration * 1_000_000_000))
        await phaseDissolveOrb()
    }

    private func phaseDissolveOrb() async {
        phase = .dissolvingOrb
        triggerSuccessHaptic.toggle()

        rippleScale = 0.5
        rippleOpacity = 0.85
        withAnimation(.easeOut(duration: 0.45)) {
            rippleScale = 1.5
            rippleOpacity = 0.0
        }

        withAnimation(MotionConfig.ringBounceSpring) {
            ringScale = 1.08
        }

        withAnimation(MotionConfig.dissolveEase) {
            orbScale = 0.0
            orbBlur = 10.0
            orbGlowOpacity = 0.0
        }

        try? await Task.sleep(nanoseconds: 220_000_000)
        withAnimation(.smooth(duration: 0.25)) {
            ringScale = 1.0
        }
        try? await Task.sleep(nanoseconds: 150_000_000)
        withAnimation(.easeInOut(duration: 0.25)) {
            isShowingAddFood = false
            phase = .completed
        }
    }

    private func mapToFoodItem(_ candidate: FoodCandidate, photo: UIImage) -> FoodItem {
        FoodItem(
            name: candidate.name,
            mealType: "1st Meal",
            dateString: dailySummary.dateString,
            calories: candidate.nutrition.calories,
            protein: candidate.nutrition.protein,
            carbs: candidate.nutrition.carbs,
            fat: candidate.nutrition.fat,
            fiber: candidate.nutrition.fiber,
            photoSystemName: "camera.fill",
            photoData: photo.jpegData(compressionQuality: 0.8)
        )
    }

    /// Converts the Feature-local, string-based `ManualIngredientInput` (from
    /// `ManualLoggingViewModel`) into the typed `ManualMealDescription` that
    /// `NutritionEstimating` expects — keeps that Core/Domain protocol from
    /// depending on a Feature-specific model (see NutritionEstimating.swift).
    /// Blank ingredient rows (the empty one `ManualLoggingViewModel` always
    /// keeps as a starting row) are skipped.
    private func mapToMealDescription(name: String, ingredients: [ManualIngredientInput]) -> ManualMealDescription {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let mealName = trimmedName.isEmpty ? "Meal" : trimmedName

        let mapped = ingredients.compactMap { input -> ManualMealDescription.Ingredient? in
            let trimmedIngredient = input.ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIngredient.isEmpty else { return nil }

            let trimmedMethod = input.cookingMethod.trimmingCharacters(in: .whitespacesAndNewlines)
            return ManualMealDescription.Ingredient(
                name: trimmedIngredient,
                portionGrams: Double(input.portionGrams.trimmingCharacters(in: .whitespacesAndNewlines)),
                cookingMethod: trimmedMethod.isEmpty ? nil : trimmedMethod
            )
        }

        return ManualMealDescription(foodName: mealName, ingredients: mapped)
    }

    private func mapToFoodItem(name: String, nutrition: NutritionFacts) -> FoodItem {
        FoodItem(
            name: name,
            mealType: "1st Meal",
            dateString: dailySummary.dateString,
            calories: nutrition.calories,
            protein: nutrition.protein,
            carbs: nutrition.carbs,
            fat: nutrition.fat,
            fiber: nutrition.fiber,
            photoSystemName: "fork.knife"
        )
    }

    /// Non-AI fallback used when `nutritionEstimator` is unavailable or fails.
    /// This is the exact gram-ratio math `handleManualCalculation` used before
    /// AI estimation existed (moved here, not deleted) — kept as a safety net
    /// so manual logging never dead-ends.
    private func legacyRatioEstimate(name: String, ingredients: [ManualIngredientInput]) -> FoodItem {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmed.isEmpty ? "Dimsum Mentai" : trimmed

        let totalGrams = ingredients.compactMap { Int($0.portionGrams) }.reduce(0, +)
        let baseGrams = totalGrams > 0 ? totalGrams : 100
        let ratio = Double(baseGrams) / 100.0

        return FoodItem(
            name: displayName,
            mealType: "1st Meal",
            dateString: dailySummary.dateString,
            calories: max(50, Int(220.0 * ratio)),
            protein: max(5, Int(15.0 * ratio)),
            carbs: max(5, Int(25.0 * ratio)),
            fat: max(2, Int(8.0 * ratio)),
            fiber: max(1, Int(2.0 * ratio)),
            photoSystemName: "fork.knife"
        )
    }

    private func executeReduceMotionFallback() {
        let newConsumed = dailySummary.consumedCalories + currentFood.calories
        dailySummary.consumedCalories = newConsumed
        let targetRatio = CGFloat(newConsumed) / CGFloat(max(1, dailySummary.targetCalories))

        withAnimation(.easeInOut(duration: 0.25)) {
            isShowingAddFood = false
            ringProgress = targetRatio
            triggerSuccessHaptic.toggle()
            phase = .completed
        }
    }
}
