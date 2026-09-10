//
//  HealthPermissionPromptView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import HealthKit
import SwiftUI

/// Onboarding screen educating user about Apple Health sync permissions.
struct HealthPermissionPromptView: View {
    @ObservedObject private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            headerSection
                .padding(.top, AppSpacing.lg)

            Spacer()

            actionSection
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xl)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Let’s Sync with Apple Health")
                .font(AppTypography.largeTitle)
                .foregroundStyle(.primary)

            Text("Sharing your activity data helps MacBite automatically adjust your daily calorie and macro goals.")
                .font(AppTypography.body)
                .foregroundStyle(.secondary)
        }
    }

    private var actionSection: some View {
        VStack(spacing: AppSpacing.md) {
            connectToHealthButton
            setupManuallyButton
            privacyDisclaimerSection
        }
    }

    private var connectToHealthButton: some View {
        Button {
            Task {
                await viewModel.connectToHealth()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
            } else {
                Text("Connect to Health")
                    .font(AppTypography.button)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.orange500)
        .disabled(viewModel.isLoading)
    }

    private var setupManuallyButton: some View {
        Button {
            viewModel.enterManually()
        } label: {
            Text("Set Up Manually")
                .font(AppTypography.button)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private var privacyDisclaimerSection: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text("Your health data will never leave this device.")
                .font(AppTypography.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(
                "MacBite is not a substitute for professional medical advice. "
                + "Always consult your physician first."
            )
            .font(AppTypography.footnote)
            .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        HealthPermissionPromptView(viewModel: OnboardingViewModel())
    }
}
