//
//  OnboardingViewModelTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

@testable import CallBite
import Testing

@Suite("OnboardingViewModel Tests")
@MainActor
struct OnboardingViewModelTests {

    @Test("Finish splash transitions to Health Prompt step")
    func finishSplashTransitionsToPrompt() {
        // Given
        let viewModel = OnboardingViewModel(
            healthKitService: MockHealthKitService(),
            initialStep: .splash
        )
        #expect(viewModel.currentStep == .splash)

        // When
        viewModel.finishSplash()

        // Then
        #expect(viewModel.currentStep == .healthPrompt)
    }

    @Test("Connect to Health opens Health Access sheet step")
    func connectToHealthOpensSheet() {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())

        // When
        viewModel.connectToHealthTapped()

        // Then
        #expect(viewModel.isHealthSheetPresented == true)
        #expect(viewModel.healthSheetStep == .access)
    }

    @Test("Allow health access authorizes service, fetches profile, and navigates to personalize")
    func allowHealthAccessFetchesProfile() async {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())

        // When
        viewModel.allowHealthAccessTapped()

        // Allow async task to complete
        try? await Task.sleep(nanoseconds: 350_000_000)

        // Then
        #expect(viewModel.isHealthAccessGranted == true)
        #expect(viewModel.healthProfile.age == 22)
        #expect(viewModel.healthProfile.biologicalSex == .male)
        #expect(viewModel.healthProfile.weightKg == 56)
        #expect(viewModel.healthProfile.heightCm == 162)
        #expect(viewModel.healthSheetStep == .personalize)
    }

    @Test("Don't allow health access still allows user to advance to personalize")
    func dontAllowHealthAccessAdvances() {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())

        // When
        viewModel.dontAllowHealthAccessTapped()

        // Then
        #expect(viewModel.isHealthAccessGranted == false)
        #expect(viewModel.healthSheetStep == .personalize)
    }

    @Test("Toggle all permissions synchronizes all three permission toggles")
    func toggleAllPermissions() {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())
        #expect(viewModel.areAllPermissionsGranted == true)

        // When toggling off
        viewModel.toggleAllPermissions()

        // Then
        #expect(viewModel.allowWeight == false)
        #expect(viewModel.allowHeight == false)
        #expect(viewModel.allowWorkouts == false)
        #expect(viewModel.areAllPermissionsGranted == false)

        // When toggling back on
        viewModel.toggleAllPermissions()
        #expect(viewModel.allowWeight == true)
        #expect(viewModel.allowHeight == true)
        #expect(viewModel.allowWorkouts == true)
        #expect(viewModel.areAllPermissionsGranted == true)
    }

    @Test("Navigation from Personalize advances to Lifestyle step and closes sheet")
    func navigationFromPersonalizeToLifestyle() {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())
        viewModel.connectToHealthTapped()
        viewModel.healthSheetStep = .personalize

        // When
        viewModel.nextFromPersonalize()

        // Then
        #expect(viewModel.isHealthSheetPresented == false)
        #expect(viewModel.currentStep == .lifestyle)
    }

    @Test("Back from Personalize returns to Health Access step")
    func backFromPersonalizeReturnsToAccess() {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())
        viewModel.healthSheetStep = .personalize

        // When
        viewModel.backFromPersonalize()

        // Then
        #expect(viewModel.healthSheetStep == .access)
    }

    @Test("Activity selection enables next button and complete executes callback")
    func activitySelectionAndCompletion() {
        // Given
        let viewModel = OnboardingViewModel(healthKitService: MockHealthKitService())
        #expect(viewModel.selectedActivity == nil)
        #expect(viewModel.canProceedFromLifestyle == false)

        // When
        viewModel.selectActivity(.moderatelyActive)

        // Then
        #expect(viewModel.selectedActivity == .moderatelyActive)
        #expect(viewModel.canProceedFromLifestyle == true)

        // When completing
        var completed = false
        viewModel.completeOnboarding {
            completed = true
        }
        #expect(completed == true)
    }
}
