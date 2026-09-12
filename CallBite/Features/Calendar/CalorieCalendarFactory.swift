//
//  CalorieCalendarFactory.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 10/09/26.
//

import Foundation
import SwiftUI

enum CalorieCalendarFactory {
    @MainActor
    static func makeView(
        summaries: [Date: DailySummary],
        selectedDate: Date,
        today: Date,
        onDismiss: @escaping () -> Void,
        onSelect: @escaping (Date) -> Void
    ) -> some View {
        let viewModel = CalorieCalendarViewModel(
            summaries: summaries,
            selectedDate: selectedDate,
            today: today
        )

        return CalorieCalendarView(
            viewModel: viewModel,
            onDismiss: onDismiss,
            onSelect: onSelect
        )
    }
}
