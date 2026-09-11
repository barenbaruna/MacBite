//
//  MacroSummaryGridView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Daily nutrition summary card displaying total calorie needs and expandable macronutrient breakdown.
public struct MacroSummaryGridView: View {
    public let consumedCalories: Int
    public let targetCalories: Int
    public let carbsGrams: Int
    public let targetCarbsGrams: Int
    public let proteinGrams: Int
    public let targetProteinGrams: Int
    public let fatGrams: Int
    public let targetFatGrams: Int
    public let fiberGrams: Int
    public let targetFiberGrams: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded: Bool

    public init(
        consumedCalories: Int = 200,
        targetCalories: Int = 2654,
        carbsGrams: Int = 17,
        targetCarbsGrams: Int = 300,
        proteinGrams: Int = 14,
        targetProteinGrams: Int = 70,
        fatGrams: Int = 17,
        targetFatGrams: Int = 70,
        fiberGrams: Int = 100,
        targetFiberGrams: Int = 70,
        initiallyExpanded: Bool = false
    ) {
        self.consumedCalories = consumedCalories
        self.targetCalories = targetCalories
        self.carbsGrams = carbsGrams
        self.targetCarbsGrams = targetCarbsGrams
        self.proteinGrams = proteinGrams
        self.targetProteinGrams = targetProteinGrams
        self.fatGrams = fatGrams
        self.targetFatGrams = targetFatGrams
        self.fiberGrams = fiberGrams
        self.targetFiberGrams = targetFiberGrams
        self._isExpanded = State(initialValue: initiallyExpanded)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            totalNeedSection

            dividerLine

            alwaysVisibleMacroRow

            if isExpanded {
                expandableMacroRow
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            expandCollapseButton
        }
        .padding(AppSpacing.dashboardMacroCardInset)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .stroke(AppColor.borderSubtle, lineWidth: 1)
                .allowsHitTesting(false)
        )
    }

    // MARK: - Sections

    private var totalNeedSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Calories")
                .font(AppTypography.body)
                .foregroundStyle(Color(uiColor: .label))

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(verbatim: "\(consumedCalories)")
                    .font(AppTypography.nutritionValue)
                    .foregroundStyle(Color(uiColor: .label))

                Text(verbatim: "/\(targetCalories) KCAL")
                    .font(AppTypography.nutritionTarget)
                    .foregroundStyle(Color(uiColor: .label))
            }
            .monospacedDigit()
        }
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color(uiColor: .separator).opacity(0.35))
            .frame(height: 1)
    }

    private var alwaysVisibleMacroRow: some View {
        HStack(spacing: AppSpacing.md) {
            MacroSummaryCell(
                title: "Carbs",
                consumedGrams: carbsGrams,
                targetGrams: targetCarbsGrams
            )
                .frame(maxWidth: .infinity, alignment: .leading)
            MacroSummaryCell(
                title: "Protein",
                consumedGrams: proteinGrams,
                targetGrams: targetProteinGrams
            )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var expandableMacroRow: some View {
        HStack(spacing: AppSpacing.md) {
            MacroSummaryCell(
                title: "Fat",
                consumedGrams: fatGrams,
                targetGrams: targetFatGrams
            )
                .frame(maxWidth: .infinity, alignment: .leading)
            MacroSummaryCell(
                title: "Fiber",
                consumedGrams: fiberGrams,
                targetGrams: targetFiberGrams
            )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var expandCollapseButton: some View {
        Button {
            AppHaptics.selectionChanged()
            withAnimation(reduceMotion ? AppAnimation.reducedMotion : AppAnimation.smooth) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Text(isExpanded ? "Show Less" : "Show More")
                    .font(AppTypography.footnote.weight(.medium))

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color(uiColor: .label))
            .frame(minHeight: AppSize.minimumTouchTarget)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MacroSummaryGridView()
            .padding()
    }
    .preferredColorScheme(.dark)
}
