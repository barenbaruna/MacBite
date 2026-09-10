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
    var onRemoveIngredient: ((UUID) -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            ForEach(Array(ingredients.enumerated()), id: \.element.id) { index, ingredient in
                ingredientCard(for: ingredient, index: index)
            }

            addIngredientButton
        }
    }

    private func ingredientCard(for ingredient: ManualIngredientInput, index: Int) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            if ingredients.count > 1 {
                cardHeader(for: ingredient, index: index)
            }

            ingredientGroup(for: ingredient)
        }
        .background(AppColor.manualFieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    private func cardHeader(for ingredient: ManualIngredientInput, index: Int) -> some View {
        HStack {
            Text("Ingredient \(index + 1)")
                .font(AppTypography.caption.weight(.semibold))
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            Spacer()

            Button(role: .destructive) {
                onRemoveIngredient?(ingredient.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(uiColor: .systemRed))
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Remove Ingredient \(index + 1)")
        }
        .padding(.horizontal, AppSpacing.regular)
        .padding(.top, AppSpacing.small)
    }

    private func ingredientGroup(for ingredient: ManualIngredientInput) -> some View {
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
