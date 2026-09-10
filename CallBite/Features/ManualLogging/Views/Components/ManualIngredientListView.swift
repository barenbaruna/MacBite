//
//  ManualIngredientListView.swift
//  CallBite
//
//  Created by Codex on 09/09/26.
//

import SwiftUI

struct ManualIngredientListView: View {
    let ingredients: [ManualIngredientInput]
    let onIngredientChanged: (UUID, String) -> Void
    let onPortionChanged: (UUID, String) -> Void
    let onCookingMethodChanged: (UUID, String) -> Void
    let onAddIngredient: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            ForEach(ingredients) { ingredient in
                ManualIngredientGroupView(
                    ingredient: ingredient,
                    onIngredientChanged: { value in
                        onIngredientChanged(ingredient.id, value)
                    },
                    onPortionChanged: { value in
                        onPortionChanged(ingredient.id, value)
                    },
                    onCookingMethodChanged: { value in
                        onCookingMethodChanged(ingredient.id, value)
                    }
                )

                Divider()
                    .overlay(AppColor.manualSeparator)
                    .padding(.horizontal, AppSpacing.regular)
            }

            Button(action: onAddIngredient) {
                Label("Add Ingredients", systemImage: "plus.circle")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: AppSize.manualAddIngredientHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.regular)
        }
        .background(AppColor.manualFieldBackground)
        .clipShape(.rect(cornerRadius: AppCornerRadius.medium))
    }
}
