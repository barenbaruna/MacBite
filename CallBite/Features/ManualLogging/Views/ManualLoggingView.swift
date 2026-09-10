//
//  ManualLoggingView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import SwiftUI

struct ManualLoggingView: View {
    @ObservedObject private var viewModel: ManualLoggingViewModel
    let onDismiss: () -> Void
    let onCalculate: (String, [ManualIngredientInput]) -> Void

    init(
        viewModel: ManualLoggingViewModel,
        onDismiss: @escaping () -> Void,
        onCalculate: @escaping (String, [ManualIngredientInput]) -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
        self.onCalculate = onCalculate
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dark950
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        foodSection
                        foodDetailsSection
                    }
                    .padding(.horizontal, AppSpacing.manualScreenMargin)
                    .padding(.top, AppSpacing.small)
                    .padding(.bottom, AppSpacing.manualSectionGap)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                calculateButton
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
        }
    }

    private var dismissButton: some View {
        Button(role: .close, action: onDismiss)
            .accessibilityLabel("Dismiss")
    }

    private var foodSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Food")
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.white)

            ManualTextInputRow(
                title: "Food Name",
                placeholder: "Dimsum",
                text: viewModel.foodName,
                onTextChanged: viewModel.updateFoodName
            )
            .background(AppColor.manualFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
    }

    private var foodDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Food Details")
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.white)

            ManualIngredientListView(
                ingredients: viewModel.ingredients,
                onIngredientChanged: { id, value in
                    viewModel.updateIngredient(value, id: id)
                },
                onPortionChanged: { id, value in
                    viewModel.updatePortionGrams(value, id: id)
                },
                onCookingMethodChanged: { id, value in
                    viewModel.updateCookingMethod(value, id: id)
                },
                onAddIngredient: viewModel.addIngredient
            )
        }
    }

    private var calculateButton: some View {
        Button {
            onCalculate(viewModel.foodName, viewModel.ingredients)
        } label: {
            Text("Calculate")
                .font(AppTypography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.calorie)
        .padding(.horizontal, AppSpacing.manualScreenMargin)
        .padding(.vertical, AppSpacing.manualBottomButtonInset)
    }
}
