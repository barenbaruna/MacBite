//
//  PersonalizeHealthView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

struct PersonalizeHealthView: View {
    @ObservedObject private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            headerSection
                .padding(.top, AppSpacing.sm)

            profileCard

            Spacer()

            nextButton
                .padding(.bottom, AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.lg)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }

    // MARK: - Subviews

    private var backButton: some View {
        Button {
            viewModel.backFromPersonalize()
        } label: {
            Image(systemName: "chevron.left")
                .font(AppTypography.headline)
                .foregroundStyle(.primary)
        }
        .accessibilityLabel("Back")
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Personalize Fitness and Health")
                .font(AppTypography.title1)
                .foregroundStyle(.primary)

            Text(
                "We use the information you share to personalize your daily calorie "
                + "needs and help you better understand your nutrition."
            )
            .font(AppTypography.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var profileCard: some View {
        VStack(spacing: 0) {
            dataRow(title: "Age", value: "\(viewModel.healthProfile.age) years")
            Divider().padding(.horizontal, AppSpacing.md)

            dataRow(title: "Sex", value: viewModel.healthProfile.biologicalSex.displayName)
            Divider().padding(.horizontal, AppSpacing.md)

            dataRow(title: "Weight", value: "\(Int(viewModel.healthProfile.weightKg))kg")
            Divider().padding(.horizontal, AppSpacing.md)

            dataRow(title: "Height", value: "\(Int(viewModel.healthProfile.heightCm))cm")
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }

    private var nextButton: some View {
        Button {
            viewModel.nextFromPersonalize()
        } label: {
            Text("Next")
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.extraLarge)
        .tint(.primary)
    }

    private func dataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    PersonalizeHealthView(viewModel: OnboardingViewModel())
        .preferredColorScheme(.dark)
}
