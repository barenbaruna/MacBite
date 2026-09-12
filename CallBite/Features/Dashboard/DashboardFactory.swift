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

        let viewModel: DashboardViewModel
        if useSampleData {
            viewModel = makeSampleViewModel(
                baseSummary: dailySummary,
                normalizedToday: normalizedToday,
                calendar: calendar
            )
        } else {
            let summary = dailySummary ?? makeDefaultSummary(
                for: today,
                normalizedToday: normalizedToday,
                calendar: calendar
            )
            viewModel = DashboardViewModel(
                dailySummary: summary,
                selectedDate: normalizedToday,
                today: normalizedToday,
                dailySummaries: [:],
                dailyFoods: [:],
                calendar: calendar
            )
        }

        return DashboardView(viewModel: viewModel)
    }

    private static func makeSampleViewModel(
        baseSummary: DailySummary?,
        normalizedToday: Date,
        calendar: Calendar
    ) -> DashboardViewModel {
        let summary = baseSummary ?? .sampleDashboard
        let sampleHistory = DashboardSampleData.makeHistory(
            endingOn: normalizedToday,
            currentSummary: summary,
            calendar: calendar
        )
        let sampleFoods = DashboardSampleData.makeFoodHistory(
            summaries: sampleHistory,
            endingOn: normalizedToday,
            calendar: calendar
        )
        let currentSummary = sampleHistory[normalizedToday] ?? summary
        return DashboardViewModel(
            dailySummary: currentSummary,
            selectedDate: normalizedToday,
            today: normalizedToday,
            dailySummaries: sampleHistory,
            dailyFoods: sampleFoods,
            calendar: calendar
        )
    }

    private static func makeDefaultSummary(
        for today: Date,
        normalizedToday: Date,
        calendar: Calendar
    ) -> DailySummary {
        let goal = UserProfileStore.shared.nutritionGoal
        return DailySummary(
            dateString: DashboardSampleData.displayDate(for: today, today: normalizedToday, calendar: calendar),
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
    }
}
