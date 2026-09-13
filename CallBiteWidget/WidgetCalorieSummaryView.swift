//
//  WidgetCalorieSummaryView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

struct WidgetCalorieSummaryView: View {
    let snapshot: CallBiteWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetSpacing.extraSmall) {
            Label("Kalori", systemImage: "flame.fill")
                .font(.caption.bold())
                .foregroundStyle(WidgetColor.calorie)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if snapshot.hasNutritionGoal {
                WidgetCalorieGoalView(snapshot: snapshot)
            } else {
                Text("Belum ada target")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Buka MacBite untuk sinkronisasi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
