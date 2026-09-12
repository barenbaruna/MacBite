//
//  DashboardFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation
import SwiftUI

/// Factory for assembling the DashboardView module with dependencies.
public enum DashboardFactory {
    public static func makeView(dailySummary: DailySummary? = nil, useSampleData: Bool = false) -> some View {
        let today = Date.now
        let calendar = Calendar.current
        let normalizedToday = calendar.startOfDay(for: today)

        if useSampleData {
            let baseSummary = dailySummary ?? .sampleDashboard
            let sampleHistory = DashboardSampleData.makeHistory(
                endingOn: normalizedToday,
                currentSummary: baseSummary,
                calendar: calendar
            )
            let sampleFoods = DashboardSampleData.makeFoodHistory(
                summaries: sampleHistory,
                endingOn: normalizedToday,
                calendar: calendar
            )
            let currentSummary = sampleHistory[normalizedToday] ?? baseSummary
            let viewModel = DashboardViewModel(
                dailySummary: currentSummary,
                selectedDate: normalizedToday,
                today: normalizedToday,
                dailySummaries: sampleHistory,
                dailyFoods: sampleFoods,
                calendar: calendar
            )
            return DashboardView(viewModel: viewModel)
        }

        let summary: DailySummary
        if let dailySummary {
            summary = dailySummary
        } else {
            let goal = UserProfileStore.shared.nutritionGoal
            let targetCalories = goal?.targetCalories ?? 2000
            let targetCarbs = goal?.targetCarbsGrams ?? 250
            let targetProtein = goal?.targetProteinGrams ?? 100
            let targetFat = goal?.targetFatGrams ?? 65
            let targetFiber = goal?.targetFiberGrams ?? 30
            summary = DailySummary(
                dateString: DashboardSampleData.displayDate(
                    for: today,
                    today: normalizedToday,
                    calendar: calendar
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
        }

        let viewModel = DashboardViewModel(
            dailySummary: summary,
            selectedDate: normalizedToday,
            today: normalizedToday,
            dailySummaries: [:],
            dailyFoods: [:],
            calendar: calendar
        )
        return DashboardView(viewModel: viewModel)
    }
}
