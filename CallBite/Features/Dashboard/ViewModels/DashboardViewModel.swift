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

    // MARK: - Initialization

    public convenience init(
        foodAnalyzer: FoodAnalyzing = CoreMLFoodAnalyzer(),
        nutritionEstimator: NutritionEstimating = FoundationModelNutritionEstimator(),
        insightGenerator: InsightGenerating = FoundationModelInsightGenerator()
    ) {
        self.init(
            dailySummary: .sampleDashboard,
            foodAnalyzer: foodAnalyzer,
            nutritionEstimator: nutritionEstimator,
            insightGenerator: insightGenerator
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
        insightGenerator: InsightGenerating = FoundationModelInsightGenerator()
    ) {
        let normalizedToday = calendar.startOfDay(for: today)
        let requestedDate = calendar.startOfDay(for: selectedDate)
        let normalizedSelectedDate = min(requestedDate, normalizedToday)
        var normalizedSummaries = dailySummaries.reduce(into: [:]) { result, entry in
            result[calendar.startOfDay(for: entry.key)] = entry.value
        }
        let normalizedFoods = dailyFoods.reduce(into: [:]) { result, entry in
            result[calendar.startOfDay(for: entry.key)] = entry.value
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

        let newConsumed = dailySummary.consumedCalories + currentFood.calories
        dailySummary.consumedCalories = newConsumed
        dailySummary.totalProtein += currentFood.protein
        dailySummary.totalCarbs += currentFood.carbs
        dailySummary.totalFat += currentFood.fat
        dailySummary.totalFiber += currentFood.fiber
        appendCurrentFoodAndStoreDay()
        refreshCoachInsight()
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

    private func executeReduceMotionFallback() {
        let newConsumed = dailySummary.consumedCalories + currentFood.calories
        dailySummary.consumedCalories = newConsumed
        dailySummary.totalProtein += currentFood.protein
        dailySummary.totalCarbs += currentFood.carbs
        dailySummary.totalFat += currentFood.fat
        dailySummary.totalFiber += currentFood.fiber
        appendCurrentFoodAndStoreDay()
        refreshCoachInsight()
        let targetRatio = CGFloat(newConsumed) / CGFloat(max(1, dailySummary.targetCalories))

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

    private func appendCurrentFoodAndStoreDay() {
        foodsForSelectedDate.append(currentFood)
        storeCurrentDay()
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
