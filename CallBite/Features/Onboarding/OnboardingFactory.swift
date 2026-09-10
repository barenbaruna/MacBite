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
}
