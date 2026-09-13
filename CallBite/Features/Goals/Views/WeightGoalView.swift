//
//  WeightGoalView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Weight goal setup view allowing continuous adjustment of target weight and category insights.
struct WeightGoalView: View {
    @State private var viewModel: WeightGoalViewModel
    @Environment(\.dismiss) private var dismiss
    public var showsDismissButton: Bool
    public var onBack: (() -> Void)?
    var onDone: ((Double, GoalCategory) -> Void)?

    init(
        currentWeightKg: Double = 60.0,
        targetWeightKg: Double? = nil,
        heightCm: Double = 168.0,
        showsDismissButton: Bool = false,
        onBack: (() -> Void)? = nil,
        onDone: ((Double, GoalCategory) -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: WeightGoalViewModel(
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                heightCm: heightCm
            )
        )
        self.showsDismissButton = showsDismissButton
        self.onBack = onBack
        self.onDone = onDone
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
                .padding(.top, AppSpacing.medium)
                .padding(.bottom, AppSpacing.extraLarge)
                .padding(.bottom, 69)

            centerContentSection

            Spacer(minLength: AppSpacing.medium)

            doneButton
                .padding(.bottom, AppSpacing.extraLarge)
        }
        .padding(.horizontal, AppSpacing.large)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onBack {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Kembali")
                }
            } else if showsDismissButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.selection, trigger: viewModel.triggerCategoryHaptic)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Let’s Set Your Target")
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text("This is a safe and realistic weight goal that can bring meaningful health benefits.")
                .font(AppTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var centerContentSection: some View {
        VStack(spacing: AppSpacing.large) {
            // 1. Goal display and category badge
            VStack(spacing: AppSpacing.extraSmall) {
                Text("Weight Goal")
                    .font(AppTypography.headline)
                    .fontWeight(.semibold)

                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.extraSmall) {
                    Text("\(Int(viewModel.targetWeightKg.rounded()))")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())

                    Text("kg")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                }
                .animation(.smooth(duration: 0.2), value: viewModel.targetWeightKg)

                dynamicGoalBadge
                    .padding(.top, AppSpacing.md)
            }

            // 2. Zone Status Label
            Text(viewModel.currentZone.title)
                .font(AppTypography.subheadline.weight(.bold))
                .foregroundStyle(Color.white)
                .tracking(0.6)
                .padding(.top, AppSpacing.large)

            // 3. Proportional 3-Zone Ruler Slider (open middle zone)
            ScientificWeightSlider(
                value: $viewModel.targetWeightKg,
                currentWeight: viewModel.currentWeightKg,
                range: viewModel.minSliderWeight...viewModel.maxSliderWeight,
                healthyRange: viewModel.healthyWeightRange
            )
            .padding(.top, AppSpacing.extraSmall)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var dynamicGoalBadge: some View {
        HStack(spacing: AppSpacing.extraSmall) {
            Image(systemName: viewModel.activeCategory.sfSymbol)
                .accessibilityHidden(true)
            Text(viewModel.activeCategory.displayName)
                .font(AppTypography.footnote.weight(.bold))
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.extraSmall)
        .background(viewModel.activeButtonColor.opacity(0.18))
        .foregroundStyle(viewModel.activeButtonColor)
        .clipShape(Capsule())
        .contentTransition(.symbolEffect(.replace))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.activeCategory)
    }

    private var doneButton: some View {
        Button {
            onDone?(viewModel.targetWeightKg, viewModel.activeCategory)
            dismiss()
        } label: {
            Text("Done")
                .font(AppTypography.button)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(viewModel.activeButtonColor)
        .animation(.easeInOut(duration: 0.25), value: viewModel.activeCategory)
    }
}

#Preview {
    WeightGoalView(currentWeightKg: 60.0, targetWeightKg: 56.0, heightCm: 168.0)
        .preferredColorScheme(.dark)
}
