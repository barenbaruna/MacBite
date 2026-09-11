//
//  LifestyleActivityView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Onboarding screen for selecting daily lifestyle activity levels.
struct LifestyleActivityView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    let onFinish: () -> Void

    init(viewModel: OnboardingViewModel, onFinish: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            headerSection
                .padding(.top, AppSpacing.medium)
                .padding(.bottom, AppSpacing.extraLarge)

            activityOptionsList

            Spacer()

            continueButton
                .padding(.bottom, AppSpacing.extraLarge)
        }
        .padding(.horizontal, AppSpacing.large)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Lifestyle Activity")
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text("Your activity data helps us adjust your daily calorie needs based on how active you are.")
                .font(AppTypography.body)
                .foregroundStyle(.secondary)
        }
    }

    private var activityOptionsList: some View {
        VStack(spacing: AppSpacing.xs) {
            ForEach(ActivityLevel.allCases) { level in
                activityCard(for: level)
            }
        }
    }

    private func activityCard(for level: ActivityLevel) -> some View {
        let isSelected = viewModel.selectedActivity == level

        return Button {
            viewModel.selectActivity(level)
        } label: {
            activityCardContent(for: level, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    private func activityCardContent(for level: ActivityLevel, isSelected: Bool) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: level.iconName)
                .font(AppTypography.title1)
                .foregroundStyle(isSelected ? AppColor.orange400 : Color(uiColor: .secondaryLabel))
                .frame(width: 32, alignment: .center)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(level.rawValue)
                    .font(AppTypography.body)
                    .foregroundStyle(.primary)

                Text(level.subtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.medium)
        .background(isSelected ? AppColor.activityCardSelected : AppColor.activityCardNormal)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .stroke(isSelected ? AppColor.activityCardSelectedBorder : Color.clear, lineWidth: 1)
        )
    }

    private var continueButton: some View {
        Button {
            viewModel.completeOnboarding(onFinish: onFinish)
        } label: {
            Text("Continue")
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.orange500)
        .disabled(!viewModel.canProceedFromLifestyle)
    }
}

#Preview {
    LifestyleActivityView(
        viewModel: OnboardingFactory.makePreviewViewModel(initialStep: .lifestyle),
        onFinish: {}
    )
    .preferredColorScheme(.dark)
}
