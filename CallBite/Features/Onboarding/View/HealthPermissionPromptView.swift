//
//  HealthPermissionPromptView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

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
        .sheet(isPresented: $viewModel.isHealthSheetPresented) {
            NavigationStack {
                sheetContent
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Let’s Sync with Apple Health")
                .font(AppTypography.title1)
                .foregroundStyle(.primary)

            Text("Sharing your activity data helps MacBite automatically adjust your daily calorie and macro goals.")
                .font(AppTypography.body)
                .foregroundStyle(.secondary)
        }
    }

    private var actionSection: some View {
        VStack(spacing: AppSpacing.md) {
            Button {
                viewModel.connectToHealthTapped()
            } label: {
                Text("Connect to Health")
                    .font(AppTypography.button)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .tint(AppColor.healthBlue)

            VStack(spacing: AppSpacing.xxs) {
                Text("Your health data will never leave this device.")
                    .font(AppTypography.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(
                    "CallBite is not a substitute for professional medical advice. "
                    + "Always consult your physician first."
                )
                .font(AppTypography.footnote)
                .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        ZStack {
            switch viewModel.healthSheetStep {
            case .access:
                HealthAccessSheetView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    ))
            case .personalize:
                PersonalizeHealthView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.healthSheetStep)
    }
}

#Preview {
    NavigationStack {
        HealthPermissionPromptView(viewModel: OnboardingViewModel())
    }
}
