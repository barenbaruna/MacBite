//
//  OnboardingContainerView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Container utama alur Onboarding MacBite berbasis NavigationStack native
struct OnboardingContainerView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    let onFinish: () -> Void

    init(viewModel: OnboardingViewModel, onFinish: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            HealthPermissionPromptView(viewModel: viewModel)
                .navigationDestination(for: OnboardingStep.self) { step in
                    destinationView(for: step)
                }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .personalize:
            PersonalizeHealthView(viewModel: viewModel)
        case .lifestyle:
            LifestyleActivityView(viewModel: viewModel, onFinish: onFinish)
        case .targetGoal:
            targetGoalStepView
        default:
            EmptyView()
        }
    }

    private var targetGoalStepView: some View {
        let profile = viewModel.healthProfile
        let currentWeight = profile.weightKg > 0 ? profile.weightKg : 60.0
        let height = profile.heightCm > 0 ? profile.heightCm : 162.0

        return WeightGoalView(
            currentWeightKg: currentWeight,
            targetWeightKg: nil,
            heightCm: height,
            onDone: { targetWeight, goalCategory in
                viewModel.saveGoal(targetWeight: targetWeight, category: goalCategory)
                onFinish()
            }
        )
    }
}

#Preview {
    OnboardingContainerView(
        viewModel: OnboardingFactory.makePreviewViewModel(initialStep: .healthPrompt),
        onFinish: {}
    )
}
