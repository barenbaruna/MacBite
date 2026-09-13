//
//  ManualIngredientListView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct ManualIngredientListView: View {
    let ingredients: [ManualIngredientInput]
    let onIngredientChanged: (UUID, String) -> Void
    let onPortionChanged: (UUID, String) -> Void
    let onAddIngredient: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            ForEach(ingredients) { ingredient in
                ingredientCard(for: ingredient)
            }

            addIngredientButton
        }
    }

    private func ingredientCard(for ingredient: ManualIngredientInput) -> some View {
        ingredientGroup(for: ingredient)
            .background(AppColor.manualFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    private func ingredientGroup(for ingredient: ManualIngredientInput) -> some View {
        ManualIngredientGroupView(
            ingredient: ingredient,
            onIngredientChanged: { value in
                onIngredientChanged(ingredient.id, value)
            },
            onPortionChanged: { value in
                onPortionChanged(ingredient.id, value)
            }
        )
    }

    private var addIngredientButton: some View {
        Button(action: onAddIngredient) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColor.calorie)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Add Ingredient")
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.extraSmall)
    }
}
