//
//  ManualIngredientGroupView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct ManualIngredientGroupView: View {
    let ingredient: ManualIngredientInput
    let onIngredientChanged: (String) -> Void
    let onPortionChanged: (String) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            ManualTextInputRow(
                title: "Ingredients",
                placeholder: "Chicken",
                text: ingredient.ingredient,
                onTextChanged: onIngredientChanged
            )

            Divider()
                .overlay(AppColor.manualSeparator)
                .padding(.horizontal, AppSpacing.regular)

            ManualTextInputRow(
                title: "Portion",
                placeholder: "100",
                text: ingredient.portionGrams,
                suffix: "g",
                onTextChanged: onPortionChanged
            )
        }
    }
}
