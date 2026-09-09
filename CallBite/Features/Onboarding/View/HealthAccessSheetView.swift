//
//  HealthAccessSheetView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

struct HealthAccessSheetView: View {
    @ObservedObject private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            introSection
                .padding(.top, AppSpacing.sm)

            turnOnAllCard
            writePermissionsSection

            Spacer()

            actionsSection
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.lg)
        .navigationTitle("Health Access")
        .toolbarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var introSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Health")
                .font(AppTypography.title2.weight(.bold))
                .foregroundStyle(.primary)

            Text("\"CallBite\" would like to access and update your Health data.")
                .font(AppTypography.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var turnOnAllCard: some View {
        Button {
            viewModel.toggleAllPermissions()
        } label: {
            Text("Turn On All")
                .font(AppTypography.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.md)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
        .buttonStyle(.plain)
    }

    private var writePermissionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Allow \"CallBite\" to write")
                .font(AppTypography.footnote)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                toggleRow(title: "Weight", isOn: $viewModel.allowWeight)
                Divider()
                    .padding(.leading, 44)
                toggleRow(title: "Height", isOn: $viewModel.allowHeight)
                Divider()
                    .padding(.leading, 44)
                toggleRow(title: "Workouts", isOn: $viewModel.allowWorkouts)
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
    }

    private var actionsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Button {
                viewModel.allowHealthAccessTapped()
            } label: {
                Text("Allow")
                    .font(AppTypography.button)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppColor.healthBlue)

            Button {
                viewModel.dontAllowHealthAccessTapped()
            } label: {
                Text("Don’t Allow")
                    .font(AppTypography.button)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.primary)
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview {
    HealthAccessSheetView(viewModel: OnboardingViewModel())
        .preferredColorScheme(.dark)
}
