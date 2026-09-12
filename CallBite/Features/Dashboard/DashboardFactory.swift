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
    public static func makeView(dailySummary: DailySummary = .sampleDashboard) -> some View {
        let today = Date.now
        let calendar = Calendar.current
        let normalizedToday = calendar.startOfDay(for: today)
        let sampleHistory = DashboardSampleData.makeHistory(
            endingOn: normalizedToday,
            currentSummary: dailySummary,
            calendar: calendar
        )
        let sampleFoods = DashboardSampleData.makeFoodHistory(
            summaries: sampleHistory,
            endingOn: normalizedToday,
            calendar: calendar
        )
        let currentSummary = sampleHistory[normalizedToday] ?? dailySummary
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
}
