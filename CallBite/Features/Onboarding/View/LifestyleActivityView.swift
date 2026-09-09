//
//  LifestyleActivityView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

struct LifestyleActivityView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    let onFinish: () -> Void

    init(viewModel: OnboardingViewModel, onFinish: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            headerSection
                .padding(.top, AppSpacing.lg)

            activityOptionsList

            Spacer()

            nextButton
                .padding(.bottom, AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Lifestyle Activity")
                .font(AppTypography.largeTitle)
                .foregroundStyle(.primary)

            Text(
                "Let me keep your calories in sync with your day. "
                + "Your activity data helps me adjust your calorie needs based on how active you are."
            )
            .font(AppTypography.body)
            .foregroundStyle(.secondary)
        }
    }

    private var activityOptionsList: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(ActivityLevel.allCases) { level in
                activityCard(for: level)
            }
        }
    }

    private func activityCard(for level: ActivityLevel) -> some View {
        let isSelected = viewModel.selectedActivity == level

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectActivity(level)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(level.rawValue)
                        .font(AppTypography.headline)
                        .foregroundStyle(.primary)

                    Text(level.subtitle)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(AppTypography.title3)
                        .foregroundStyle(AppColor.healthBlue)
                        .accessibilityLabel("Selected")
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(
                        isSelected ? AppColor.healthBlue : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var nextButton: some View {
        Button {
            viewModel.completeOnboarding(onFinish: onFinish)
        } label: {
            Text("Next")
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(
            viewModel.canProceedFromLifestyle
            ? AppColor.primary500
            : AppColor.buttonDisabled
        )
        .disabled(!viewModel.canProceedFromLifestyle)
        .animation(.easeInOut(duration: 0.2), value: viewModel.canProceedFromLifestyle)
    }
}

#Preview {
    NavigationStack {
        LifestyleActivityView(
            viewModel: OnboardingViewModel(),
            onFinish: {}
        )
    }
}
