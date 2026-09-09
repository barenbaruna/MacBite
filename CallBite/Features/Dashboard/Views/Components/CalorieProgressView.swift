//
//  CalorieProgressView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Komponen visual progres kalori terhadap target harian
struct CalorieProgressView: View {
    let summary: DailySummary

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Calories")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(Int(summary.consumedCalories)) / \(Int(summary.targetCalories)) kcal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
