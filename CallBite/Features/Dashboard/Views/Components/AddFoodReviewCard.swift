//
//  AddFoodReviewCard.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI
import UIKit

/// Full-page native food details review card with interactive macro editing and 3D flip confirmation.
public struct AddFoodReviewCard: View {
    @Binding public var foodItem: FoodItem
    public let isCompressed: Bool
    public let flipAngle: Double
    public let isSaveDisabled: Bool
    public let safeArea: EdgeInsets
    public let onDismiss: () -> Void
    public let onSave: () -> Void

    @FocusState private var focusedField: EditableField?
    @State private var isEditingName = false

    private enum EditableField: Hashable {
        case nutrition(NutritionEditField)
    }

    public init(
        foodItem: Binding<FoodItem>,
        isCompressed: Bool = false,
        flipAngle: Double = 0.0,
        isSaveDisabled: Bool = false,
        safeArea: EdgeInsets = EdgeInsets(),
        onDismiss: @escaping () -> Void = {},
        onSave: @escaping () -> Void = {}
    ) {
        self._foodItem = foodItem
        self.isCompressed = isCompressed
        self.flipAngle = flipAngle
        self.isSaveDisabled = isSaveDisabled
        self.safeArea = safeArea
        self.onDismiss = onDismiss
        self.onSave = onSave
    }

    public var body: some View {
        ZStack {
            confirmationBackFace
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipAngle >= 90 ? 1.0 : 0.0)

            frontDetailsFace
                .opacity(flipAngle < 90 ? 1.0 : 0.0)
        }
        .clipShape(RoundedRectangle(cornerRadius: isCompressed ? AppCornerRadius.modalCard : 0, style: .continuous))
    }

    // MARK: - Front Face

    private var frontDetailsFace: some View {
        NavigationStack {
            frontDetailsContent
                .background(AppColor.backgroundGrouped)
                .navigationTitle("Food Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    detailsToolbar
                    keyboardToolbar
                }
                .sheet(isPresented: $isEditingName) {
                    nameEditModal
                }
        }
    }

    @ToolbarContentBuilder
    private var detailsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Back", systemImage: "chevron.left", action: onDismiss)
                .labelStyle(.iconOnly)
                .font(AppTypography.headline)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.regular)
        }

        ToolbarItem(placement: .principal) {
            Text("Food Details")
                .font(AppTypography.title2.weight(.bold))
                .foregroundStyle(AppColor.white)
        }
    }

    private var mealTimeSlot: MealTimeSlot {
        MealTimeSlot.slot(forMealType: foodItem.mealType)
    }

    private var frontDetailsContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                foodPhotoView

                mealMetadataText

                nutritionSummaryCard
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            saveFoodButton
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, bottomButtonInset)
        }
        .onTapGesture {
            focusedField = nil
        }
        .accessibilityAction(named: "Dismiss Keyboard") {
            focusedField = nil
        }
    }

    @ViewBuilder
    private var foodPhotoView: some View {
        if let photoData = foodItem.photoData,
           let photo = UIImage(data: photoData) {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: isCompressed ? 160 : 210)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous))
                .accessibilityLabel("Food photo")
        } else if let photoAssetName = foodItem.photoAssetName {
            Image(photoAssetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: isCompressed ? 160 : 210)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous))
                .accessibilityLabel("Food photo")
        }
    }

    private var mealMetadataText: some View {
        Text("\(foodItem.mealType) | \(foodItem.dateString)")
            .font(AppTypography.caption2)
            .foregroundStyle(AppColor.foodDetailSecondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var nutritionSummaryCard: some View {
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

    private var rowDivider: some View {
        Divider()
            .background(Color(uiColor: .separator).opacity(0.35))
    }

    private func nutritionInputRow(
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
                .onSubmit {
                    focusedField = nil
                }
                .accessibilityLabel(field.rawValue)

                Text(verbatim: field.unit)
                    .font(AppTypography.body)
                    .foregroundStyle(nutritionInputColor(for: field))
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }

    private func nutritionInputColor(for field: NutritionEditField) -> Color {
        focusedField == .nutrition(field)
            ? AppColor.foodDetailActiveInput
            : AppColor.foodDetailSecondaryText
    }

    private var saveFoodButton: some View {
        Button(action: onSave) {
            Text("Save Food")
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.orange500)
        .disabled(isSaveDisabled)
    }

    // MARK: - Back Face (3D Flip Confirmation)

    private var confirmationBackFace: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient.foodConfirmation)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppColor.orange500.opacity(0.30), radius: 12, y: 4)

                Image(systemName: "checkmark")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }
            .symbolEffect(.bounce.byLayer, value: flipAngle >= 90)

            VStack(spacing: AppSpacing.xs) {
                Text("Your Food has been Saved")
                    .font(AppTypography.title2.weight(.bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .multilineTextAlignment(.center)

                Text(mealTimeSlot.greetingMessage)
                    .font(AppTypography.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.orange500)

                Text("+\(foodItem.calories) kcal from \(foodItem.name)")
                    .font(AppTypography.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }

            Spacer()
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dynamicGlassSurface(cornerRadius: isCompressed ? AppCornerRadius.modalCard : 0)
    }
}

private extension AddFoodReviewCard {
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

    var nameEditModal: some View {
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

    var bottomButtonInset: CGFloat {
        if focusedField != nil {
            return AppSpacing.manualBottomButtonInset
        }
        return isCompressed ? AppSpacing.md : max(safeArea.bottom, AppSpacing.lg)
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

private extension LinearGradient {
    static let foodConfirmation = LinearGradient(
        colors: [AppColor.orange400, AppColor.orange500],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

#Preview {
    AddFoodReviewCard(
        foodItem: .constant(.dimsumMentai),
        isCompressed: false,
        flipAngle: 0.0
    )
    .preferredColorScheme(.dark)
}
