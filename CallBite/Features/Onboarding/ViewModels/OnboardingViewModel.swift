//
//  OnboardingViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Combine
import Foundation
import UIKit

enum OnboardingStep: Int, CaseIterable {
    case splash = 0
    case healthPrompt = 1
    case lifestyle = 2
}

enum HealthSheetStep: Equatable {
    case access
    case personalize
}

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var currentStep: OnboardingStep
    @Published var isHealthSheetPresented: Bool = false
    @Published var healthSheetStep: HealthSheetStep = .access
    @Published private(set) var healthProfile: UserHealthProfile = .empty
    @Published private(set) var selectedActivity: ActivityLevel?
    @Published private(set) var isHealthAccessGranted: Bool = false
    @Published private(set) var isLoading: Bool = false

    // State dummy toggle untuk HealthAccessSheet
    @Published var allowWeight: Bool = true
    @Published var allowHeight: Bool = true
    @Published var allowWorkouts: Bool = true

    // MARK: - Computed Properties

    var canProceedFromLifestyle: Bool {
        selectedActivity != nil
    }

    var areAllPermissionsGranted: Bool {
        allowWeight && allowHeight && allowWorkouts
    }

    // MARK: - Dependencies

    private let healthKitService: HealthServiceProtocol

    // MARK: - Initialization

    init(
        healthKitService: HealthServiceProtocol = MockHealthKitService(),
        initialStep: OnboardingStep = .splash
    ) {
        self.healthKitService = healthKitService
        self.currentStep = initialStep
    }

    // MARK: - Public Methods

    func finishSplash() {
        currentStep = .healthPrompt
    }

    func connectToHealthTapped() {
        healthSheetStep = .access
        isHealthSheetPresented = true
    }

    func allowHealthAccessTapped() {
        Task {
            await grantHealthAccess()
            healthSheetStep = .personalize
        }
    }

    func dontAllowHealthAccessTapped() {
        isHealthAccessGranted = false
        healthSheetStep = .personalize
    }

    func toggleAllPermissions() {
        let shouldTurnOn = !areAllPermissionsGranted
        allowWeight = shouldTurnOn
        allowHeight = shouldTurnOn
        allowWorkouts = shouldTurnOn
    }

    func dismissHealthSheet() {
        isHealthSheetPresented = false
    }

    func backFromPersonalize() {
        healthSheetStep = .access
    }

    func nextFromPersonalize() {
        isHealthSheetPresented = false
        currentStep = .lifestyle
    }

    func selectActivity(_ level: ActivityLevel) {
        selectedActivity = level
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func backToHealthPrompt() {
        currentStep = .healthPrompt
    }

    func completeOnboarding(onFinish: () -> Void) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        onFinish()
    }

    // MARK: - Private Methods

    private func grantHealthAccess() async {
        isLoading = true
        defer { isLoading = false }

        _ = try? await healthKitService.requestAuthorization()

        if let profile = try? await healthKitService.fetchProfile() {
            healthProfile = profile
        }

        isHealthAccessGranted = true
    }
}
