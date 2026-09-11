//
//  MacroSummaryCell.swift
//  CallBite
//
//  Created by Codex on 11/09/26.
//

import SwiftUI

struct MacroSummaryCell: View {
    let title: String
    let consumedGrams: Int
    let targetGrams: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(Color(uiColor: .label))

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(verbatim: "\(consumedGrams)")
                    .font(AppTypography.nutritionValue)

                Text(verbatim: "/\(targetGrams)g")
                    .font(AppTypography.nutritionTarget)
            }
            .foregroundStyle(Color(uiColor: .label))
            .monospacedDigit()
            .contentTransition(.numericText())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(consumedGrams) of \(targetGrams) grams")
    }
}

#Preview {
    MacroSummaryCell(title: "Protein", consumedGrams: 14, targetGrams: 70)
        .padding()
        .preferredColorScheme(.dark)
}
