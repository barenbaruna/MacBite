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
    @FocusState private var focusedField: EditableField?

    public let onSave: (FoodItem) -> Void

    private enum EditableField: Hashable {
        case nutrition(NutritionEditField)
    }

    public init(
        foodItem: FoodItem,
        onSave: @escaping (FoodItem) -> Void = { _ in }
    ) {
        self._foodItem = State(initialValue: foodItem)
        self.onSave = onSave
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
        .onTapGesture {
            focusedField = nil
        }
        .accessibilityAction(named: "Dismiss Keyboard") {
            focusedField = nil
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditingName) { nameEditSheet }
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
            AppHaptics.selectionChanged()
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
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .contentShape(Rectangle())
        .onTapGesture {
            AppHaptics.selectionChanged()
            focusedField = .nutrition(field)
        }
    }

    func nutritionInputColor(for field: NutritionEditField) -> Color {
        focusedField == .nutrition(field)
            ? AppColor.foodDetailActiveInput
            : AppColor.foodDetailSecondaryText
    }

    var actionsSection: some View {
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
}

#Preview {
    NavigationStack {
        FoodDetailView(foodItem: .dimsumMentai)
    }
    .preferredColorScheme(.dark)
}
