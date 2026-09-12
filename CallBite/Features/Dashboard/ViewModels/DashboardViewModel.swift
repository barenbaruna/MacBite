//
//  DashboardViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Combine
import SwiftUI

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
    @Published public private(set) var selectedDate: Date
    @Published public private(set) var foodsForSelectedDate: [FoodItem]

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
    @Published public var nonFoodWarningMessage: String?
    @Published public var isAnalyzing: Bool = false
    @Published public var analysisMessage: String = ""

    // AI Coach Insight — always has a value (rule-based fallback set
    // synchronously in init, potentially replaced by the AI-generated
    // version shortly after; see DashboardViewModel+Insight.swift).
    @Published public var coachInsight: String = ""

    // MARK: - Dependencies

    private let dateCalendar: Calendar
    private let normalizedToday: Date
    private var dailySummariesByDate: [Date: DailySummary]
    private var dailyFoodsByDate: [Date: [FoodItem]]
    let foodAnalyzer: FoodAnalyzing
    let nutritionEstimator: NutritionEstimating
    let insightGenerator: InsightGenerating
    private let mealStore: MealStoreProtocol

    // MARK: - Initialization

    public convenience init(
        foodAnalyzer: FoodAnalyzing = CoreMLFoodAnalyzer(),
        nutritionEstimator: NutritionEstimating = FoundationModelNutritionEstimator(),
        insightGenerator: InsightGenerating = FoundationModelInsightGenerator(),
        mealStore: MealStoreProtocol? = nil
    ) {
        let goal = UserProfileStore.shared.nutritionGoal
        let targetCalories = goal?.targetCalories ?? 2000
        let targetCarbs = goal?.targetCarbsGrams ?? 250
        let targetProtein = goal?.targetProteinGrams ?? 100
        let targetFat = goal?.targetFatGrams ?? 65
        let targetFiber = goal?.targetFiberGrams ?? 30
        let summary = DailySummary(
            dateString: DashboardSampleData.displayDate(
                for: .now,
                today: .now,
                calendar: .current
            ),
            targetCalories: targetCalories,
            consumedCalories: 0,
            targetCarbs: targetCarbs,
            targetProtein: targetProtein,
            targetFat: targetFat,
            targetFiber: targetFiber,
            totalCarbs: 0,
            totalProtein: 0,
            totalFat: 0,
            totalFiber: 0,
            streakDays: 0
        )

        self.init(
            dailySummary: summary,
            dailySummaries: [:],
            dailyFoods: [:],
            foodAnalyzer: foodAnalyzer,
            nutritionEstimator: nutritionEstimator,
            insightGenerator: insightGenerator,
            mealStore: mealStore
        )
    }

    public init(
        dailySummary: DailySummary,
        initialFood: FoodItem? = nil,
        selectedDate: Date = .now,
        today: Date = .now,
        dailySummaries: [Date: DailySummary] = [:],
        dailyFoods: [Date: [FoodItem]] = [:],
        calendar: Calendar = .current,
        foodAnalyzer: FoodAnalyzing = CoreMLFoodAnalyzer(),
        nutritionEstimator: NutritionEstimating = FoundationModelNutritionEstimator(),
        insightGenerator: InsightGenerating = FoundationModelInsightGenerator(),
        mealStore: MealStoreProtocol? = nil
    ) {
        let resolvedStore = mealStore ?? SwiftDataMealStore.defaultStore()
        let normalizedToday = calendar.startOfDay(for: today)
        let requestedDate = calendar.startOfDay(for: selectedDate)
        let normalizedSelectedDate = min(requestedDate, normalizedToday)
        var normalizedSummaries = dailySummaries.reduce(into: [:]) { result, entry in
            result[calendar.startOfDay(for: entry.key)] = entry.value
        }
        var normalizedFoods = dailyFoods.reduce(into: [:]) { result, entry in
            result[calendar.startOfDay(for: entry.key)] = entry.value
        }

        if dailyFoods.isEmpty {
            let storedMealsByDate = (try? resolvedStore.fetchAllMeals()) ?? [:]
            for (date, meals) in storedMealsByDate {
                let normalizedDay = calendar.startOfDay(for: date)
                if normalizedFoods[normalizedDay] == nil {
                    normalizedFoods[normalizedDay] = meals
                }
            }
        }

        for (date, foods) in normalizedFoods {
            if let existing = normalizedSummaries[date] {
                var updated = existing
                if updated.consumedCalories == 0 && !foods.isEmpty {
                    updated.consumedCalories = foods.reduce(0) { $0 + $1.calories }
                    updated.totalProtein = foods.reduce(0) { $0 + $1.protein }
                    updated.totalCarbs = foods.reduce(0) { $0 + $1.carbs }
                    updated.totalFat = foods.reduce(0) { $0 + $1.fat }
                    updated.totalFiber = foods.reduce(0) { $0 + $1.fiber }
                }
                normalizedSummaries[date] = updated
            } else {
                let dateStr = DashboardSampleData.displayDate(for: date, today: normalizedToday, calendar: calendar)
                normalizedSummaries[date] = DailySummary(
                    dateString: dateStr,
                    targetCalories: dailySummary.targetCalories,
                    consumedCalories: foods.reduce(0) { $0 + $1.calories },
                    targetCarbs: dailySummary.targetCarbs,
                    targetProtein: dailySummary.targetProtein,
                    targetFat: dailySummary.targetFat,
                    targetFiber: dailySummary.targetFiber,
                    totalCarbs: foods.reduce(0) { $0 + $1.carbs },
                    totalProtein: foods.reduce(0) { $0 + $1.protein },
                    totalFat: foods.reduce(0) { $0 + $1.fat },
                    totalFiber: foods.reduce(0) { $0 + $1.fiber },
                    streakDays: dailySummary.streakDays
                )
            }
        }

        if normalizedSummaries[normalizedSelectedDate] == nil {
            normalizedSummaries[normalizedSelectedDate] = dailySummary
        }

        let initialSummary = normalizedSummaries[normalizedSelectedDate] ?? dailySummary

        self.dateCalendar = calendar
        self.normalizedToday = normalizedToday
        self.selectedDate = normalizedSelectedDate
        self.dailySummariesByDate = normalizedSummaries
        self.dailyFoodsByDate = normalizedFoods
        self.dailySummary = initialSummary
        self.foodsForSelectedDate = normalizedFoods[normalizedSelectedDate] ?? []
        self.currentFood = initialFood ?? FoodItem.dimsumMentai
        self.foodAnalyzer = foodAnalyzer
        self.nutritionEstimator = nutritionEstimator
        self.insightGenerator = insightGenerator
        self.mealStore = resolvedStore

        let currentRatio = Self.rawProgress(for: initialSummary)
        self.ringProgress = currentRatio
        self.orbProgress = Double(currentRatio)
        #if DEBUG
        print("[DashboardViewModel] init (dailySummary:) -> \(ObjectIdentifier(self))")
        #endif
        refreshCoachInsight()
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

        let targetRatio = applyCurrentFoodAndStoreDay()

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

    private func executeReduceMotionFallback() {
        let targetRatio = applyCurrentFoodAndStoreDay()

        withAnimation(.easeInOut(duration: 0.25)) {
            isShowingAddFood = false
            ringProgress = targetRatio
            triggerSuccessHaptic.toggle()
            phase = .completed
        }
    }

    private func emptySummary(for date: Date) -> DailySummary {
        DailySummary(
            dateString: DashboardSampleData.displayDate(
                for: date,
                today: normalizedToday,
                calendar: dateCalendar
            ),
            targetCalories: dailySummary.targetCalories,
            consumedCalories: 0,
            targetCarbs: dailySummary.targetCarbs,
            targetProtein: dailySummary.targetProtein,
            targetFat: dailySummary.targetFat,
            targetFiber: dailySummary.targetFiber,
            totalCarbs: 0,
            totalProtein: 0,
            totalFat: 0,
            totalFiber: 0,
            streakDays: 0
        )
    }

    private func storeCurrentDay() {
        dailySummariesByDate[selectedDate] = dailySummary
        dailyFoodsByDate[selectedDate] = foodsForSelectedDate
    }

    @discardableResult
    private func applyCurrentFoodAndStoreDay() -> CGFloat {
        if let index = foodsForSelectedDate.firstIndex(where: { $0.id == currentFood.id }) {
            let oldFood = foodsForSelectedDate[index]
            let updatedCalories = dailySummary.consumedCalories - oldFood.calories + currentFood.calories
            dailySummary.consumedCalories = max(0, updatedCalories)
            let updatedProtein = dailySummary.totalProtein - oldFood.protein + currentFood.protein
            dailySummary.totalProtein = max(0, updatedProtein)
            let updatedCarbs = dailySummary.totalCarbs - oldFood.carbs + currentFood.carbs
            dailySummary.totalCarbs = max(0, updatedCarbs)
            let updatedFat = dailySummary.totalFat - oldFood.fat + currentFood.fat
            dailySummary.totalFat = max(0, updatedFat)
            let updatedFiber = dailySummary.totalFiber - oldFood.fiber + currentFood.fiber
            dailySummary.totalFiber = max(0, updatedFiber)
            foodsForSelectedDate[index] = currentFood
        } else {
            dailySummary.consumedCalories += currentFood.calories
            dailySummary.totalProtein += currentFood.protein
            dailySummary.totalCarbs += currentFood.carbs
            dailySummary.totalFat += currentFood.fat
            dailySummary.totalFiber += currentFood.fiber
            foodsForSelectedDate.append(currentFood)
        }
        storeCurrentDay()
        try? mealStore.saveMeal(currentFood, for: selectedDate)
        refreshCoachInsight()
        return CGFloat(dailySummary.consumedCalories) / CGFloat(max(1, dailySummary.targetCalories))
    }

    /// Deletes a logged food item and updates summary metrics accordingly.
    public func deleteFood(_ food: FoodItem) {
        guard let index = foodsForSelectedDate.firstIndex(where: { $0.id == food.id }) else { return }
        let removed = foodsForSelectedDate.remove(at: index)
        dailySummary.consumedCalories = max(0, dailySummary.consumedCalories - removed.calories)
        dailySummary.totalProtein = max(0, dailySummary.totalProtein - removed.protein)
        dailySummary.totalCarbs = max(0, dailySummary.totalCarbs - removed.carbs)
        dailySummary.totalFat = max(0, dailySummary.totalFat - removed.fat)
        dailySummary.totalFiber = max(0, dailySummary.totalFiber - removed.fiber)
        storeCurrentDay()
        syncProgressWithDailySummary()
        try? mealStore.deleteMeal(id: food.id)
        refreshCoachInsight()
    }

    private func syncProgressWithDailySummary() {
        let progress = Self.rawProgress(for: dailySummary)
        ringProgress = progress
        orbProgress = Double(progress)
        ringScale = 1
        rippleScale = 0.5
        rippleOpacity = 0
    }

    private static func rawProgress(for summary: DailySummary) -> CGFloat {
        CGFloat(summary.consumedCalories) / CGFloat(max(1, summary.targetCalories))
    }

    /// Updates the daily summary targets with a new nutrition goal (e.g. after Profile edit).
    /// Preserves consumed amounts and recalculates progress ring.
    public func updateNutritionTargets(_ goal: NutritionGoal) {
        dailySummary.targetCalories = goal.targetCalories
        dailySummary.targetCarbs = goal.targetCarbsGrams
        dailySummary.targetProtein = goal.targetProteinGrams
        dailySummary.targetFat = goal.targetFatGrams
        dailySummary.targetFiber = goal.targetFiberGrams

        dailySummariesByDate[selectedDate] = dailySummary
        syncProgressWithDailySummary()
    }
}

// MARK: - Date Navigation

public extension DashboardViewModel {
    var isShowingToday: Bool {
        dateCalendar.isDate(selectedDate, inSameDayAs: normalizedToday)
    }

    var todayDate: Date {
        normalizedToday
    }

    var calendarSummaries: [Date: DailySummary] {
        var summaries = dailySummariesByDate
        summaries[selectedDate] = dailySummary
        return summaries
    }

    @discardableResult
    func selectDate(_ date: Date) -> Bool {
        let normalizedDate = dateCalendar.startOfDay(for: date)
        guard normalizedDate <= normalizedToday else { return false }

        storeCurrentDay()
        selectedDate = normalizedDate

        if dailyFoodsByDate[normalizedDate] == nil {
            if let fetched = try? mealStore.fetchMeals(for: normalizedDate) {
                dailyFoodsByDate[normalizedDate] = fetched
                if dailySummariesByDate[normalizedDate] == nil {
                    var summary = emptySummary(for: normalizedDate)
                    summary.consumedCalories = fetched.reduce(0) { $0 + $1.calories }
                    summary.totalProtein = fetched.reduce(0) { $0 + $1.protein }
                    summary.totalCarbs = fetched.reduce(0) { $0 + $1.carbs }
                    summary.totalFat = fetched.reduce(0) { $0 + $1.fat }
                    summary.totalFiber = fetched.reduce(0) { $0 + $1.fiber }
                    dailySummariesByDate[normalizedDate] = summary
                }
            }
        }

        dailySummary = dailySummariesByDate[normalizedDate] ?? emptySummary(for: normalizedDate)
        foodsForSelectedDate = dailyFoodsByDate[normalizedDate] ?? []
        syncProgressWithDailySummary()
        hideLoggingOptions()
        refreshCoachInsight()
        return true
    }

    func returnToToday() {
        selectDate(normalizedToday)
    }
}
