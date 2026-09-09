//
//  OnboardingContainerView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

struct OnboardingContainerView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    let onFinish: () -> Void

    init(viewModel: OnboardingViewModel, onFinish: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.currentStep {
                case .splash:
                    SplashScreenView(
                        appName: "CallBite",
                        tagline: "Food Analysis Camera Companion",
                        onFinish: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                viewModel.finishSplash()
                            }
                        }
                    )
                    .transition(.opacity)

                case .healthPrompt:
                    HealthPermissionPromptView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.96)),
                            removal: .move(edge: .leading)
                        ))

                case .lifestyle:
                    LifestyleActivityView(viewModel: viewModel, onFinish: onFinish)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .trailing)
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentStep)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    OnboardingContainerView(
        viewModel: OnboardingViewModel(),
        onFinish: {}
    )
}
