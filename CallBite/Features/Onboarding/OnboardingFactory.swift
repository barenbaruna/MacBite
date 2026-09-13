//
//  OnboardingFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Factory for assembling the Onboarding flow.
enum OnboardingFactory {
    @MainActor
    static func makeView(onFinish: @escaping () -> Void) -> some View {
        let viewModel = OnboardingViewModel(initialStep: .healthPrompt)
        return OnboardingContainerView(viewModel: viewModel, onFinish: onFinish)
    }

    @MainActor
    static func makePreviewViewModel(initialStep: OnboardingStep = .personalize) -> OnboardingViewModel {
        OnboardingViewModel(
            healthKitService: MockHealthKitService(),
            profileStore: UserProfileStore(defaults: UserDefaults(suiteName: "preview") ?? .standard),
            initialStep: initialStep
        )
    }
}
