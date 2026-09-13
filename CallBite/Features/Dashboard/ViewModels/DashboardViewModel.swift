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
    @Published public internal(set) var selectedDate: Date
    @Published public internal(set) var foodsForSelectedDate: [FoodItem]

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

    // AI Coach Insight
    @Published public var coachInsight: String = ""

    // MARK: - Dependencies

    let dateCalendar: Calendar
    let normalizedToday: Date
    var dailySummariesByDate: [Date: DailySummary]
    var dailyFoodsByDate: [Date: [FoodItem]]
    let foodAnalyzer: FoodAnalyzing
    let nutritionEstimator: NutritionEstimating
    let insightGenerator: InsightGenerating
    let mealStore: MealStoreProtocol
    let widgetSnapshotSynchronizer: WidgetSnapshotSynchronizer

    // MARK: - Initialization

    public convenience init(
        foodAnalyzer: FoodAnalyzing = CoreMLFoodAnalyzer(),
        nutritionEstimator: NutritionEstimating = FoundationModelNutritionEstimator(),
        insightGenerator: InsightGenerating = FoundationModelInsightGenerator(),
        mealStore: MealStoreProtocol? = nil,
        widgetSnapshotSynchronizer: WidgetSnapshotSynchronizer? = nil
    ) {
        let goal = UserProfileStore.shared.nutritionGoal
        let summary = DailySummary(
            dateString: DashboardSampleData.displayDate(for: .now, today: .now, calendar: .current),
            targetCalories: goal?.targetCalories ?? 2000,
            consumedCalories: 0,
            targetCarbs: goal?.targetCarbsGrams ?? 250,
            targetProtein: goal?.targetProteinGrams ?? 100,
            targetFat: goal?.targetFatGrams ?? 65,
            targetFiber: goal?.targetFiberGrams ?? 30,
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
            mealStore: mealStore,
            widgetSnapshotSynchronizer: widgetSnapshotSynchronizer
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
        mealStore: MealStoreProtocol? = nil,
        widgetSnapshotSynchronizer: WidgetSnapshotSynchronizer? = nil
    ) {
        let resolvedStore = mealStore ?? SwiftDataMealStore.defaultStore()
        let resolvedWidgetSnapshotSynchronizer = widgetSnapshotSynchronizer ?? .live()
        let normalizedToday = calendar.startOfDay(for: today)
        let requestedDate = calendar.startOfDay(for: selectedDate)
        let normalizedSelectedDate = min(requestedDate, normalizedToday)

        let context = DashboardInitContext(
            dailySummary: dailySummary,
            dailySummaries: dailySummaries,
            dailyFoods: dailyFoods,
            normalizedSelectedDate: normalizedSelectedDate,
            normalizedToday: normalizedToday,
            calendar: calendar,
            resolvedStore: resolvedStore
        )
        let initialData = Self.prepareInitialData(context: context)

        self.dateCalendar = calendar
        self.normalizedToday = normalizedToday
        self.selectedDate = normalizedSelectedDate
        self.dailySummariesByDate = initialData.summaries
        self.dailyFoodsByDate = initialData.foods
        self.dailySummary = initialData.initialSummary
        self.foodsForSelectedDate = initialData.foods[normalizedSelectedDate] ?? []
        self.currentFood = initialFood ?? FoodItem.dimsumMentai
        self.foodAnalyzer = foodAnalyzer
        self.nutritionEstimator = nutritionEstimator
        self.insightGenerator = insightGenerator
        self.mealStore = resolvedStore
        self.widgetSnapshotSynchronizer = resolvedWidgetSnapshotSynchronizer

        let currentRatio = Self.rawProgress(for: initialData.initialSummary)
        self.ringProgress = currentRatio
        self.orbProgress = Double(currentRatio)
        refreshCoachInsight()
        resolvedWidgetSnapshotSynchronizer.synchronize(
            initialData.initialSummary,
            for: normalizedSelectedDate,
            today: normalizedToday
        )
    }

    private static func prepareInitialData(context: DashboardInitContext) -> InitialDashboardData {
        let calendar = context.calendar
        var normalizedSummaries = context.dailySummaries.reduce(into: [:]) { res, entry in
            res[calendar.startOfDay(for: entry.key)] = entry.value
        }
        var normalizedFoods = context.dailyFoods.reduce(into: [:]) { res, entry in
            res[calendar.startOfDay(for: entry.key)] = entry.value
        }

        if context.dailyFoods.isEmpty {
            let storedMealsByDate = (try? context.resolvedStore.fetchAllMeals()) ?? [:]
            for (date, meals) in storedMealsByDate {
                let normalizedDay = calendar.startOfDay(for: date)
                if normalizedFoods[normalizedDay] == nil {
                    normalizedFoods[normalizedDay] = meals
                }
            }
        }

        populateSummaries(
            summaries: &normalizedSummaries,
            foods: normalizedFoods,
            dailySummary: context.dailySummary,
            normalizedToday: context.normalizedToday,
            calendar: calendar
        )

        let initialSummary = normalizedSummaries[context.normalizedSelectedDate] ?? context.dailySummary
        return InitialDashboardData(
            summaries: normalizedSummaries,
            foods: normalizedFoods,
            initialSummary: initialSummary
        )
    }

    private static func populateSummaries(
        summaries: inout [Date: DailySummary],
        foods: [Date: [FoodItem]],
        dailySummary: DailySummary,
        normalizedToday: Date,
        calendar: Calendar
    ) {
        for (date, foodList) in foods {
            if let existing = summaries[date] {
                var updated = existing
                if updated.consumedCalories == 0 && !foodList.isEmpty {
                    updated.consumedCalories = foodList.reduce(0) { $0 + $1.calories }
                    updated.totalProtein = foodList.reduce(0) { $0 + $1.protein }
                    updated.totalCarbs = foodList.reduce(0) { $0 + $1.carbs }
                    updated.totalFat = foodList.reduce(0) { $0 + $1.fat }
                    updated.totalFiber = foodList.reduce(0) { $0 + $1.fiber }
                }
                summaries[date] = updated
            } else {
                let dateStr = DashboardSampleData.displayDate(for: date, today: normalizedToday, calendar: calendar)
                summaries[date] = DailySummary(
                    dateString: dateStr,
                    targetCalories: dailySummary.targetCalories,
                    consumedCalories: foodList.reduce(0) { $0 + $1.calories },
                    targetCarbs: dailySummary.targetCarbs,
                    targetProtein: dailySummary.targetProtein,
                    targetFat: dailySummary.targetFat,
                    targetFiber: dailySummary.targetFiber,
                    totalCarbs: foodList.reduce(0) { $0 + $1.carbs },
                    totalProtein: foodList.reduce(0) { $0 + $1.protein },
                    totalFat: foodList.reduce(0) { $0 + $1.fat },
                    totalFiber: foodList.reduce(0) { $0 + $1.fiber },
                    streakDays: dailySummary.streakDays
                )
            }
        }
    }
}

private struct DashboardInitContext {
    let dailySummary: DailySummary
    let dailySummaries: [Date: DailySummary]
    let dailyFoods: [Date: [FoodItem]]
    let normalizedSelectedDate: Date
    let normalizedToday: Date
    let calendar: Calendar
    let resolvedStore: MealStoreProtocol
}

private struct InitialDashboardData {
    let summaries: [Date: DailySummary]
    let foods: [Date: [FoodItem]]
    let initialSummary: DailySummary
}
