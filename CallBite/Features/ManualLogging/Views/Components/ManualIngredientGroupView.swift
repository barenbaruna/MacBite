//
//  ManualIngredientGroupView.swift
//  CallBite
//
//  Created by Codex on 09/09/26.
//

import SwiftUI

struct ManualIngredientGroupView: View {
    let ingredient: ManualIngredientInput
    let onIngredientChanged: (String) -> Void
    let onPortionChanged: (String) -> Void
    let onCookingMethodChanged: (String) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            ManualTextInputRow(
                title: "Ingredients",
                placeholder: "Ingredient",
                text: ingredient.ingredient,
                onTextChanged: onIngredientChanged
            )

            Divider()
                .overlay(AppColor.manualSeparator)
                .padding(.horizontal, AppSpacing.regular)

            ManualTextInputRow(
                title: "Portion",
                placeholder: "0",
                text: ingredient.portionGrams,
                suffix: "g",
                onTextChanged: onPortionChanged
            )

            Divider()
                .overlay(AppColor.manualSeparator)
                .padding(.horizontal, AppSpacing.regular)

            ManualTextInputRow(
                title: "Cooking Method",
                placeholder: "Optional",
                text: ingredient.cookingMethod,
                onTextChanged: onCookingMethodChanged
            )
        }
    }
}
