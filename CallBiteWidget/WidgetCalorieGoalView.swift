//
//  WidgetCalorieGoalView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

struct WidgetCalorieGoalView: View {
    let snapshot: CallBiteWidgetSnapshot

    private var isOverTarget: Bool {
        snapshot.consumedCalories > snapshot.targetCalories
    }

    private var overlimitAmount: Int {
        snapshot.consumedCalories - snapshot.targetCalories
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetSpacing.extraSmall) {
            calorieValuesRow
            calorieProgressBar
            calorieStatusLabel
        }
    }

    private var calorieValuesRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: WidgetSpacing.extraSmall) {
            Text(snapshot.consumedCalories, format: .number)
                .font(.title2.bold())
                .foregroundStyle(isOverTarget ? WidgetColor.calorieOverlimit : .primary)
                .monospacedDigit()

            Text("/ \(snapshot.targetCalories) kkal")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private var calorieProgressBar: some View {
        ProgressView(
            value: Double(snapshot.consumedCalories),
            total: Double(max(1, snapshot.targetCalories))
        )
        .tint(isOverTarget ? WidgetColor.calorieOverlimit : WidgetColor.calorie)
        .accessibilityLabel("Progres kalori")
        .accessibilityValue(
            "\(snapshot.consumedCalories) dari \(snapshot.targetCalories) kilokalori"
        )
    }

    private var calorieStatusLabel: some View {
        Group {
            if isOverTarget {
                Text("\(overlimitAmount) kkal berlebih")
                    .foregroundStyle(WidgetColor.calorieOverlimit)
            } else {
                Text("\(snapshot.remainingCalories) kkal tersisa")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption.weight(isOverTarget ? .medium : .regular))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
}
