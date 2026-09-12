//
//  DashboardViewModel+Persistence.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import SwiftUI

// MARK: - Meal Persistence & Date Navigation

extension DashboardViewModel {
    func emptySummary(for date: Date) -> DailySummary {
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

    func storeCurrentDay() {
        dailySummariesByDate[selectedDate] = dailySummary
        dailyFoodsByDate[selectedDate] = foodsForSelectedDate
    }

    @discardableResult
    func applyCurrentFoodAndStoreDay() -> CGFloat {
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

    /// Updates an existing logged food item, recalculates daily metrics, syncs the ring, and persists to store.
    public func updateFood(_ food: FoodItem) {
        currentFood = food
        applyCurrentFoodAndStoreDay()
        syncProgressWithDailySummary()
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

    func syncProgressWithDailySummary() {
        let progress = Self.rawProgress(for: dailySummary)
        ringProgress = progress
        orbProgress = Double(progress)
        ringScale = 1
        rippleScale = 0.5
        rippleOpacity = 0
    }

    static func rawProgress(for summary: DailySummary) -> CGFloat {
        CGFloat(summary.consumedCalories) / CGFloat(max(1, summary.targetCalories))
    }

    /// Updates the daily summary targets with a new nutrition goal (e.g. after Profile edit).
    public func updateNutritionTargets(_ goal: NutritionGoal) {
        dailySummary.targetCalories = goal.targetCalories
        dailySummary.targetCarbs = goal.targetCarbsGrams
        dailySummary.targetProtein = goal.targetProteinGrams
        dailySummary.targetFat = goal.targetFatGrams
        dailySummary.targetFiber = goal.targetFiberGrams

        dailySummariesByDate[selectedDate] = dailySummary
        syncProgressWithDailySummary()
    }

    // MARK: - Date Navigation

    public var isShowingToday: Bool {
        dateCalendar.isDate(selectedDate, inSameDayAs: normalizedToday)
    }

    public var todayDate: Date {
        normalizedToday
    }

    public var calendarSummaries: [Date: DailySummary] {
        var summaries = dailySummariesByDate
        summaries[selectedDate] = dailySummary
        return summaries
    }

    @discardableResult
    public func selectDate(_ date: Date) -> Bool {
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

    public func returnToToday() {
        selectDate(normalizedToday)
    }
}
