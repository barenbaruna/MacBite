//
//  CalorieCalendarScrollContentView.swift
//  CallBite
//
//  Created by Codex on 11/09/26.
//

import SwiftUI

struct CalorieCalendarScrollContentView: View {
    @ObservedObject var viewModel: CalorieCalendarViewModel
    @Binding var visibleMonthID: Date?

    let onSelect: (Date) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,
                spacing: AppSpacing.calendarMonthSpacing
            ) {
                ForEach(viewModel.months) { month in
                    CalorieCalendarMonthView(
                        month: month,
                        viewModel: viewModel,
                        onSelect: onSelect
                    )
                }
            }
            .scrollTargetLayout()
            .padding(.vertical, AppSpacing.medium)
        }
        .contentMargins(
            .horizontal,
            AppSpacing.calendarSheetInset,
            for: .scrollContent
        )
        .scrollPosition(id: $visibleMonthID, anchor: .top)
    }
}

#Preview {
    @Previewable @State var visibleMonthID: Date?
    let viewModel = CalorieCalendarViewModel(
        summaries: DashboardSampleData.makeHistory(
            endingOn: .now,
            currentSummary: .sampleDashboard
        ),
        selectedDate: .now,
        today: .now
    )

    CalorieCalendarScrollContentView(
        viewModel: viewModel,
        visibleMonthID: $visibleMonthID,
        onSelect: { _ in }
    )
    .preferredColorScheme(.dark)
}
