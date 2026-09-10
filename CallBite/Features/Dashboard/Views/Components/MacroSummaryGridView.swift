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
    public let proteinGrams: Int
    public let fatGrams: Int
    public let fiberGrams: Int

    @State private var isExpanded: Bool

    public init(
        consumedCalories: Int = 200,
        targetCalories: Int = 2654,
        carbsGrams: Int = 17,
        proteinGrams: Int = 100,
        fatGrams: Int = 17,
        fiberGrams: Int = 100,
        initiallyExpanded: Bool = false
    ) {
        self.consumedCalories = consumedCalories
        self.targetCalories = targetCalories
        self.carbsGrams = carbsGrams
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
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
        .padding(AppSpacing.lg)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .stroke(AppColor.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Sections

    private var totalNeedSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Total Need")
                .font(AppTypography.subheadline)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(verbatim: "\(consumedCalories)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(uiColor: .label))

                Text(verbatim: "/\(targetCalories) KCAL")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
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
            macroCell(title: "Carbs", value: "\(carbsGrams)g")
                .frame(maxWidth: .infinity, alignment: .leading)
            macroCell(title: "Protein", value: "\(proteinGrams)g")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var expandableMacroRow: some View {
        HStack(spacing: AppSpacing.md) {
            macroCell(title: "Fat", value: "\(fatGrams)g")
                .frame(maxWidth: .infinity, alignment: .leading)
            macroCell(title: "Fiber", value: "\(fiberGrams)g")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var expandCollapseButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
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
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .frame(maxWidth: .infinity)
            .padding(.top, AppSpacing.xxs)
        }
        .buttonStyle(.plain)
    }

    private func macroCell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            Text(verbatim: value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color(uiColor: .label))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
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
