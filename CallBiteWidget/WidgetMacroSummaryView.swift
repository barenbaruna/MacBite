//
//  WidgetMacroSummaryView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

struct WidgetMacroSummaryView: View {
    let snapshot: CallBiteWidgetSnapshot

    var body: some View {
        VStack(spacing: WidgetSpacing.small) {
            WidgetMacroValueView(
                title: "Protein",
                systemImage: "figure.strengthtraining.traditional",
                consumed: snapshot.proteinGrams,
                target: snapshot.targetProteinGrams,
                color: WidgetColor.protein
            )
            WidgetMacroValueView(
                title: "Karbo",
                systemImage: "leaf.fill",
                consumed: snapshot.carbsGrams,
                target: snapshot.targetCarbsGrams,
                color: WidgetColor.carbs
            )
            WidgetMacroValueView(
                title: "Lemak",
                systemImage: "drop.fill",
                consumed: snapshot.fatGrams,
                target: snapshot.targetFatGrams,
                color: WidgetColor.fat
            )
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
