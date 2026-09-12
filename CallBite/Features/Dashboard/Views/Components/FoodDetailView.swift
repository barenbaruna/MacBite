//
//  FoodDetailView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 12/09/26.
//

import SwiftUI
import UIKit

/// Full-page native food details view pushed onto NavigationStack for viewing and editing logged meals.
public struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var foodItem: FoodItem
    @State private var isEditingName = false
    @State private var isShowingDeleteConfirmation = false
    @FocusState private var focusedField: EditableField?

    public let onSave: (FoodItem) -> Void
    public let onDelete: (FoodItem) -> Void

    private enum EditableField: Hashable {
        case nutrition(NutritionEditField)
    }

    public init(
        foodItem: FoodItem,
        onSave: @escaping (FoodItem) -> Void = { _ in },
        onDelete: @escaping (FoodItem) -> Void = { _ in }
    ) {
        self._foodItem = State(initialValue: foodItem)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                foodPhotoView

                mealMetadataText

                nutritionSummaryCard

                actionsSection
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColor.backgroundGrouped)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { keyboardToolbar }
        .sheet(isPresented: $isEditingName) { nameEditSheet }
        .confirmationDialog(
            "Delete Meal",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Meal", role: .destructive) {
                onDelete(foodItem)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this meal? This action cannot be undone.")
        }
    }
}

// MARK: - Subviews

private extension FoodDetailView {
    @ViewBuilder
    var foodPhotoView: some View {
        if let photoData = foodItem.photoData,
           let photo = UIImage(data: photoData) {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 210)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous))
                .accessibilityLabel("Food photo")
        } else if let photoAssetName = foodItem.photoAssetName {
            Image(photoAssetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 210)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous))
                .accessibilityLabel("Food photo")
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous)
                    .fill(AppColor.activityCardNormal)
                    .frame(height: 160)

                Image(systemName: foodItem.photoSystemName)
                    .font(.system(size: 48))
                    .foregroundStyle(AppColor.orange400)
                    .accessibilityHidden(true)
            }
        }
    }

    var mealMetadataText: some View {
        Text("\(foodItem.mealType) | \(foodItem.dateString)")
            .font(AppTypography.caption2)
            .foregroundStyle(AppColor.foodDetailSecondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var nutritionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            editableNameRow
                .padding(.bottom, AppSpacing.md)

            nutritionInputRow(field: .calories, value: $foodItem.calories)
            rowDivider
            nutritionInputRow(field: .protein, value: $foodItem.protein)
            rowDivider
            nutritionInputRow(field: .carbs, value: $foodItem.carbs)
            rowDivider
            nutritionInputRow(field: .fat, value: $foodItem.fat)
            rowDivider
            nutritionInputRow(field: .fiber, value: $foodItem.fiber)
        }
        .padding(AppSpacing.md)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
    }

    var editableNameRow: some View {
        Button {
            isEditingName = true
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Text(foodItem.name)
                    .font(AppTypography.title2.weight(.bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .multilineTextAlignment(.leading)

                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    .accessibilityHidden(true)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit food name, currently \(foodItem.name)")
    }

    var rowDivider: some View {
        Divider()
            .background(Color(uiColor: .separator).opacity(0.35))
    }

    func nutritionInputRow(
        field: NutritionEditField,
        value: Binding<Int>
    ) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text(field.rawValue)
                .font(AppTypography.body)
                .foregroundStyle(Color(uiColor: .label))
                .layoutPriority(1)
                .accessibilityIdentifier("Food Detail \(field.rawValue) Label")

            Spacer(minLength: AppSpacing.sm)

            HStack(spacing: 4) {
                TextField("0", text: Binding(
                    get: { "\(value.wrappedValue)" },
                    set: { newText in
                        let digitsOnly = newText.filter { $0.isNumber }
                        value.wrappedValue = max(0, Int(digitsOnly) ?? 0)
                    }
                ))
                .font(AppTypography.body)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(nutritionInputColor(for: field))
                .monospacedDigit()
                .focused($focusedField, equals: .nutrition(field))
                .submitLabel(.done)
                .onSubmit { focusedField = nil }
                .accessibilityLabel(field.rawValue)

                Text(verbatim: field.unit)
                    .font(AppTypography.body)
                    .foregroundStyle(nutritionInputColor(for: field))
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }

    func nutritionInputColor(for field: NutritionEditField) -> Color {
        focusedField == .nutrition(field)
            ? AppColor.foodDetailActiveInput
            : AppColor.foodDetailSecondaryText
    }

    var actionsSection: some View {
        VStack(spacing: AppSpacing.md) {
            Button {
                onSave(foodItem)
                dismiss()
            } label: {
                Text("Save Changes")
                    .font(AppTypography.button)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .tint(AppColor.orange500)

            Button(role: .destructive) {
                isShowingDeleteConfirmation = true
            } label: {
                Text("Delete Meal")
                    .font(AppTypography.body.weight(.medium))
                    .foregroundStyle(.red)
            }
            .padding(.top, AppSpacing.xs)
        }
        .padding(.top, AppSpacing.md)
    }

    var nameEditSheet: some View {
        FoodNameEditSheet(
            initialValue: foodItem.name,
            onSave: { updated in
                foodItem.name = updated
                isEditingName = false
            },
            onCancel: {
                isEditingName = false
            }
        )
    }

    @ToolbarContentBuilder
    var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                focusedField = nil
            }
            .font(AppTypography.headline)
            .foregroundStyle(AppColor.orange500)
        }
    }
}

#Preview {
    NavigationStack {
        FoodDetailView(foodItem: .dimsumMentai)
    }
    .preferredColorScheme(.dark)
}
