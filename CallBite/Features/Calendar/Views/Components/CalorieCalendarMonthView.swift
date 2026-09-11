//
//  CalorieCalendarMonthView.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import SwiftUI

struct CalorieCalendarMonthView: View {
    let month: CalorieCalendarMonth
    @ObservedObject var viewModel: CalorieCalendarViewModel
    let onSelect: (Date) -> Void

    private var columns: [GridItem] {
        viewModel.weekdaySymbols.map { _ in
            GridItem(.flexible(), spacing: .zero)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.calendarHeaderSpacing) {
            Text(viewModel.monthTitle(for: month))
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.white)

            LazyVGrid(columns: columns, spacing: AppSpacing.calendarGridSpacing) {
                ForEach(viewModel.weekdaySymbols.indices, id: \.self) { index in
                    Text(viewModel.weekdaySymbols[index])
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.gray300)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }

                ForEach(month.days) { day in
                    CalorieCalendarDayButton(
                        day: day,
                        isSelected: viewModel.isSelected(day),
                        isToday: viewModel.isToday(day),
                        accessibilityLabel: viewModel.accessibilityLabel(for: day),
                        action: {
                            guard let date = viewModel.select(day) else { return }
                            AppHaptics.selectionChanged()
                            onSelect(date)
                        }
                    )
                }
            }
        }
        .id(month.id)
    }
}
