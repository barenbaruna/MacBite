//
//  WidgetCalorieGoalView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

struct WidgetCalorieGoalView: View {
    let snapshot: CallBiteWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetSpacing.extraSmall) {
            HStack(alignment: .firstTextBaseline, spacing: WidgetSpacing.extraSmall) {
                Text(snapshot.consumedCalories, format: .number)
                    .font(.title2.bold())
                    .monospacedDigit()

                Text("/ \(snapshot.targetCalories) kkal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            ProgressView(
                value: Double(snapshot.consumedCalories),
                total: Double(max(1, snapshot.targetCalories))
            )
            .tint(WidgetColor.calorie)
            .accessibilityLabel("Progres kalori")
            .accessibilityValue(
                "\(snapshot.consumedCalories) dari \(snapshot.targetCalories) kilokalori"
            )

            Text("\(snapshot.remainingCalories) kkal tersisa")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}
