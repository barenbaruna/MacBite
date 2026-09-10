//
//  DashboardFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Factory for assembling the DashboardView module with dependencies.
public enum DashboardFactory {
    public static func makeView(dailySummary: DailySummary = .sampleDashboard) -> some View {
        let viewModel = DashboardViewModel(dailySummary: dailySummary)
        return DashboardView(viewModel: viewModel)
    }
}
