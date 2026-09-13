//
//  OnboardingViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Combine
import Foundation
import UIKit

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var navigationPath: [OnboardingStep] = [] {
        didSet {
            let active = navigationPath.last ?? .healthPrompt
            if currentStep != active {
                currentStep = active
            }
        }
    }
    @Published private(set) var currentStep: OnboardingStep
    @Published private(set) var healthProfile: UserHealthProfile = .empty
    @Published private(set) var selectedActivity: ActivityLevel?
    @Published private(set) var isHealthAccessGranted: Bool = false
    @Published private(set) var isLoading: Bool = false

    // MARK: - Computed Properties

    var canProceedFromLifestyle: Bool {
        selectedActivity != nil
    }

    var calculatedBMR: Double {
        GoalCalculator.calculateBMR(profile: healthProfile)
    }

    var calculatedTDEE: Double {
        guard let activity = selectedActivity else { return 0.0 }
        return GoalCalculator.calculateTDEE(bmr: calculatedBMR, activityLevel: activity)
    }

    func calculatedDailyCalories(for category: GoalCategory) -> Int {
        GoalCalculator.calculateDailyCalorieTarget(tdee: calculatedTDEE, category: category)
    }

    func calculatedNutritionGoal(for category: GoalCategory) -> NutritionGoal {
        let calories = calculatedDailyCalories(for: category)
        return GoalCalculator.calculateMacronutrients(dailyCalories: calories)
    }

    // MARK: - Dependencies

    private let healthKitService: HealthServiceProtocol
    private let profileStore: UserProfileStore

    // MARK: - Initialization

    init(
        healthKitService: HealthServiceProtocol? = nil,
        profileStore: UserProfileStore = .shared,
        initialStep: OnboardingStep = .splash
    ) {
        self.healthKitService = healthKitService ?? HealthKitClient.shared
        self.profileStore = profileStore
        self.currentStep = initialStep
        if initialStep == .personalize {
            self.navigationPath = [.personalize]
        } else if initialStep == .lifestyle {
            self.navigationPath = [.lifestyle]
        } else if initialStep == .targetGoal {
            self.navigationPath = [.lifestyle, .targetGoal]
        }
    }

    // MARK: - Public Methods

    func finishSplash() {
        currentStep = .healthPrompt
    }

    func connectToHealth() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let authorized = try await healthKitService.requestAuthorization()
            print("[OnboardingViewModel] HealthKit requestAuthorization completed. Authorized: \(authorized)")
        } catch {
            print("[OnboardingViewModel] HealthKit requestAuthorization failed: \(error.localizedDescription)")
        }

        let profile = (try? await healthKitService.fetchProfile()) ?? .empty
        healthProfile = profile

        // Health data is considered complete only if age, valid biologicalSex (!= .notSet),
        // and at least one physical metric (height or weight) were retrieved from HealthKit.
        let hasHealthData = profile.age > 0
            && profile.biologicalSex != .notSet
            && (profile.heightCm > 0 || profile.weightKg > 0)

        if hasHealthData {
            isHealthAccessGranted = true
            currentStep = .lifestyle
            navigationPath = [.lifestyle]
        } else {
            isHealthAccessGranted = false
            currentStep = .personalize
            navigationPath = [.personalize]
        }
    }

    func enterManually() {
        isHealthAccessGranted = false
        currentStep = .personalize
        navigationPath = [.personalize]
    }

    func saveManualProfile(age: Int, sex: BiologicalSex, heightCm: Double, weightKg: Double) {
        healthProfile = UserHealthProfile(
            age: max(1, age),
            biologicalSex: sex,
            weightKg: weightKg,
            heightCm: heightCm
        )
        currentStep = .lifestyle
        navigationPath = [.personalize, .lifestyle]
    }

    func saveManualProfile(dateOfBirth: Date, sex: BiologicalSex, heightCm: Double, weightKg: Double) {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let calculatedAge = max(1, ageComponents.year ?? 25)

        saveManualProfile(
            age: calculatedAge,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg
        )
    }

    func cancelPersonalize() {
        currentStep = .healthPrompt
        navigationPath = []
    }

    func nextFromPersonalize() {
        currentStep = .lifestyle
        navigationPath = [.personalize, .lifestyle]
    }

    func goBackFromLifestyle() {
        if isHealthAccessGranted {
            currentStep = .healthPrompt
            navigationPath = []
        } else {
            currentStep = .personalize
            navigationPath = [.personalize]
        }
    }

    func goBackFromTargetGoal() {
        currentStep = .lifestyle
        navigationPath = isHealthAccessGranted ? [.lifestyle] : [.personalize, .lifestyle]
    }

    func selectActivity(_ level: ActivityLevel) {
        selectedActivity = level
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func backToHealthPrompt() {
        currentStep = .healthPrompt
        navigationPath = []
    }

    func completeOnboarding(onFinish: () -> Void) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        currentStep = .targetGoal
        navigationPath = isHealthAccessGranted ? [.lifestyle, .targetGoal] : [.personalize, .lifestyle, .targetGoal]
    }

    func saveGoal(targetWeight: Double, category: GoalCategory) {
        healthProfile.targetWeightKg = targetWeight
        healthProfile.goalCategory = category
    }

    /// Persists all onboarding data (profile + activity + goal) to disk and
    /// marks onboarding as complete. Called at the very end of the onboarding flow.
    func finalizeOnboarding() {
        guard let activity = selectedActivity else {
            #if DEBUG
            print("[OnboardingViewModel] finalizeOnboarding called without selectedActivity")
            #endif
            return
        }

        profileStore.saveOnboardingResult(
            profile: healthProfile,
            activityLevel: activity
        )
    }
}
