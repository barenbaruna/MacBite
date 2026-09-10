//
//  AddFoodReviewCard.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Full-page native food details review card with interactive macro editing and 3D flip confirmation.
public struct AddFoodReviewCard: View {
    @Binding public var foodItem: FoodItem
    public let isCompressed: Bool
    public let flipAngle: Double
    public let isSaveDisabled: Bool
    public let safeArea: EdgeInsets
    public let onDismiss: () -> Void
    public let onSave: () -> Void

    @State private var activeFieldForEdit: NutritionEditField?

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
                .navigationTitle("Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { detailsToolbar }
                .sheet(item: $activeFieldForEdit) { field in
                    nutritionFieldEditModal(for: field)
                }
        }
    }

    @ToolbarContentBuilder
    private var detailsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .close, action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.regular)
            .accessibilityLabel("Dismiss Details")
        }
    }

    private func nutritionFieldEditModal(for field: NutritionEditField) -> some View {
        NutritionEditSheet(
            field: field,
            initialValue: currentValue(for: field),
            onSave: { updated in
                applyValue(updated, for: field)
                activeFieldForEdit = nil
            },
            onCancel: {
                activeFieldForEdit = nil
            }
        )
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }

    private var frontDetailsContent: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    photoPlaceholderView

                    badgeAndDateRow

                    nutritionSummaryCard
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)
            }

            Spacer(minLength: 0)

            saveFoodButton
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, isCompressed ? AppSpacing.md : max(safeArea.bottom, AppSpacing.lg))
        }
    }

    private var photoPlaceholderView: some View {
        RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous)
            .fill(Color(uiColor: .systemGray5))
            .frame(height: isCompressed ? 160 : 210)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: isCompressed ? 48 : 64, weight: .regular))
                    .foregroundStyle(Color(uiColor: .systemGray3))
                    .accessibilityHidden(true)
            )
    }

    private var badgeAndDateRow: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(foodItem.mealType)
                .font(AppTypography.caption2.weight(.semibold))
                .foregroundStyle(Color(uiColor: .label))
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs + 2)
                .background(Color(uiColor: .secondarySystemFill))
                .clipShape(Capsule())

            Text(foodItem.dateString)
                .font(AppTypography.subheadline)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            Spacer()
        }
    }

    private var nutritionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(foodItem.name)
                .font(AppTypography.title2.weight(.bold))
                .foregroundStyle(Color(uiColor: .label))
                .padding(.bottom, AppSpacing.md)

            nutritionRowButton(title: "Calories", value: "\(foodItem.calories)kcal") {
                activeFieldForEdit = .calories
            }

            rowDivider

            nutritionRowButton(title: "Protein", value: "\(foodItem.protein)g") {
                activeFieldForEdit = .protein
            }

            rowDivider

            nutritionRowButton(title: "Carbs", value: "\(foodItem.carbs)g") {
                activeFieldForEdit = .carbs
            }

            rowDivider

            nutritionRowButton(title: "Fat", value: "\(foodItem.fat)g") {
                activeFieldForEdit = .fat
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
    }

    private var rowDivider: some View {
        Divider()
            .background(Color(uiColor: .separator).opacity(0.35))
    }

    private func nutritionRowButton(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(Color(uiColor: .label))

                Spacer()

                HStack(spacing: 6) {
                    Text(value)
                        .font(AppTypography.body)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, AppSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    private func currentValue(for field: NutritionEditField) -> Int {
        switch field {
        case .calories: return foodItem.calories
        case .protein: return foodItem.protein
        case .carbs: return foodItem.carbs
        case .fat: return foodItem.fat
        }
    }

    private func applyValue(_ value: Int, for field: NutritionEditField) {
        switch field {
        case .calories: foodItem.calories = value
        case .protein: foodItem.protein = value
        case .carbs: foodItem.carbs = value
        case .fat: foodItem.fat = value
        }
    }

    // MARK: - Back Face (3D Flip Confirmation)

    private var confirmationBackFace: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColor.orange400, AppColor.orange500],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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

                Text("+\(foodItem.calories) kcal from \(foodItem.name)")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }

            Spacer()
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dynamicGlassSurface(cornerRadius: isCompressed ? AppCornerRadius.modalCard : 0)
    }
}

#Preview {
    AddFoodReviewCard(
        foodItem: .constant(.dimsumMentai),
        isCompressed: false,
        flipAngle: 0.0
    )
    .preferredColorScheme(.dark)
}
