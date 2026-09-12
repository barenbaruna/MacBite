//
//  CalorieCalendarView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 10/09/26.
//

import SwiftUI

struct CalorieCalendarView: View {
    @ObservedObject private var viewModel: CalorieCalendarViewModel
    @State private var visibleMonthID: Date?

    private let onDismiss: () -> Void
    private let onSelect: (Date) -> Void

    init(
        viewModel: CalorieCalendarViewModel,
        onDismiss: @escaping () -> Void,
        onSelect: @escaping (Date) -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._visibleMonthID = State(initialValue: viewModel.todayMonthID)
        self.onDismiss = onDismiss
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            CalorieCalendarScrollContentView(
                viewModel: viewModel,
                visibleMonthID: $visibleMonthID,
                onSelect: onSelect
            )
            .background(AppColor.activityCardNormal)
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close, action: onDismiss)
                        .accessibilityLabel("Tutup Kalender")
                }
            }
        }
    }
}

#Preview {
    CalorieCalendarView(
        viewModel: CalorieCalendarViewModel(
            summaries: DashboardSampleData.makeHistory(
                endingOn: .now,
                currentSummary: .sampleDashboard
            ),
            selectedDate: .now,
            today: .now
        ),
        onDismiss: {},
        onSelect: { _ in }
    )
    .preferredColorScheme(.dark)
}
