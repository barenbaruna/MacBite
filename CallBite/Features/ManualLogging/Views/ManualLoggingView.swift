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
        ZStack {
            AppColor.dark950
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.manualSectionGap) {
                    header
                    formCard
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
    }

    private var header: some View {
        HStack {
            Text("Log Meal")
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.white)

            Spacer()

            Button(role: .close, action: onDismiss) {
                Image(systemName: "xmark")
                    .font(AppTypography.body)
                    .frame(
                        width: AppSize.minimumTouchTarget,
                        height: AppSize.minimumTouchTarget
                    )
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Close")
        }
    }

    private var formCard: some View {
        VStack(spacing: AppSpacing.small) {
            ManualTextInputRow(
                title: "Food Name",
                placeholder: "Meal name",
                text: viewModel.foodName,
                onTextChanged: viewModel.updateFoodName
            )
            .background(AppColor.manualFieldBackground)
            .clipShape(.rect(cornerRadius: AppCornerRadius.medium))

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
        .padding(AppSpacing.manualCardInset)
        .background(AppColor.dark900)
        .clipShape(.rect(cornerRadius: AppCornerRadius.medium))
    }

    private var calculateButton: some View {
        Button {
            onCalculate(viewModel.foodName, viewModel.ingredients)
        } label: {
            Text("Calculate")
                .font(AppTypography.button)
                .foregroundStyle(AppColor.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppSize.manualCalculateHeight)
                .background(AppColor.orange400)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.manualScreenMargin)
        .padding(.vertical, AppSpacing.manualBottomButtonInset)
        .background(AppColor.dark950)
    }
}
