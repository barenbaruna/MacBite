//
//  OnboardingFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

enum OnboardingFactory {
    @MainActor
    static func makeView(onFinish: @escaping () -> Void = {}) -> some View {
        let healthService = MockHealthKitService()
        let viewModel = OnboardingViewModel(healthKitService: healthService)
        return OnboardingContainerView(viewModel: viewModel, onFinish: onFinish)
    }
}
