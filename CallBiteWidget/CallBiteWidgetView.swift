//
//  CallBiteWidgetView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI
import WidgetKit

struct CallBiteWidgetView: View {
    let entry: CallBiteWidgetEntry

    var body: some View {
        VStack(spacing: WidgetSpacing.small) {
            HStack(alignment: .top, spacing: WidgetSpacing.regular) {
                WidgetCalorieSummaryView(snapshot: entry.snapshot)
                WidgetMacroSummaryView(snapshot: entry.snapshot)
            }
            .frame(maxHeight: .infinity, alignment: .top)

            WidgetLoggingActionsView()
        }
        .containerBackground(WidgetColor.background, for: .widget)
    }
}

#Preview(as: .systemMedium) {
    CallBiteWidget()
} timeline: {
    CallBiteWidgetEntry(
        date: .now,
        snapshot: CallBiteWidgetSnapshot(
            date: .now,
            consumedCalories: 1_240,
            targetCalories: 2_000,
            proteinGrams: 72,
            targetProteinGrams: 100,
            carbsGrams: 138,
            targetCarbsGrams: 250,
            fatGrams: 41,
            targetFatGrams: 65,
            updatedAt: .now
        )
    )
}
