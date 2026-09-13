//
//  CalorieCalendarDayButton.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 10/09/26.
//

import SwiftUI

struct CalorieCalendarDayButton: View {
    let day: CalorieCalendarDay
    let isSelected: Bool
    let isToday: Bool
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Group {
            if let dayNumber = day.dayNumber {
                Button(action: action) {
                    CalendarDayProgressView(
                        dayNumber: dayNumber,
                        summary: day.summary
                    )
                    .overlay {
                        if isSelected || isToday {
                            selectionIndicator
                        }
                    }
                    .frame(
                        minWidth: AppSize.minimumTouchTarget,
                        minHeight: AppSize.minimumTouchTarget
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!day.isSelectable)
                .opacity(day.isSelectable ? 1 : AppMetrics.calendarDisabledOpacity)
                .accessibilityLabel(accessibilityLabel)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            } else {
                Color.clear
                    .frame(
                        minWidth: AppSize.minimumTouchTarget,
                        minHeight: AppSize.minimumTouchTarget
                    )
                    .accessibilityHidden(true)
            }
        }
    }

    private var selectionIndicator: some View {
        Circle()
            .stroke(
                isSelected ? AppColor.white : AppColor.ringYellow,
                lineWidth: AppSize.calendarDaySelectionStroke
            )
            .frame(
                width: AppSize.calendarDaySelection,
                height: AppSize.calendarDaySelection
            )
    }
}
