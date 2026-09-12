//
//  UserProfileStoreTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

@testable import CallBite
import Foundation
import Testing

@Suite("UserProfileStore Tests")
struct UserProfileStoreTests {
    private func makeIsolatedStore() -> (UserProfileStore, UserDefaults) {
        let suiteName = "test.userProfileStore.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = UserProfileStore(defaults: defaults)
        return (store, defaults)
    }

    @Test("Store starts with nil profile and hasCompletedOnboarding false")
    func startsEmpty() {
        let (store, _) = makeIsolatedStore()

        #expect(store.hasCompletedOnboarding == false)
        #expect(store.healthProfile == nil)
        #expect(store.activityLevel == nil)
        #expect(store.nutritionGoal == nil)
    }

    @Test("Save onboarding result persists health profile and activity level")
    func saveOnboardingResultPersists() {
        let (store, _) = makeIsolatedStore()

        let profile = UserHealthProfile(
            age: 24,
            biologicalSex: .female,
            weightKg: 55.0,
            heightCm: 165.0,
            targetWeightKg: 52.0,
            goalCategory: .cutting
        )

        store.saveOnboardingResult(profile: profile, activityLevel: .moderatelyActive)

        #expect(store.hasCompletedOnboarding == true)
        #expect(store.healthProfile?.age == 24)
        #expect(store.healthProfile?.biologicalSex == .female)
        #expect(store.healthProfile?.weightKg == 55.0)
        #expect(store.healthProfile?.heightCm == 165.0)
        #expect(store.healthProfile?.targetWeightKg == 52.0)
        #expect(store.healthProfile?.goalCategory == .cutting)
        #expect(store.activityLevel == .moderatelyActive)

        // Verify computed nutrition goal is valid and accurate
        let goal = store.nutritionGoal
        #expect(goal != nil)
        #expect((goal?.targetCalories ?? 0) >= 1200)
        #expect((goal?.targetProteinGrams ?? 0) > 0)
        #expect((goal?.targetCarbsGrams ?? 0) > 0)
        #expect((goal?.targetFatGrams ?? 0) > 0)
    }

    @Test("Data persists across different instances sharing the same UserDefaults")
    func persistsAcrossInstances() {
        let suiteName = "test.userProfileStore.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let storeA = UserProfileStore(defaults: defaults)
        let profile = UserHealthProfile(
            age: 28,
            biologicalSex: .male,
            weightKg: 75.0,
            heightCm: 178.0,
            targetWeightKg: 80.0,
            goalCategory: .bulking
        )
        storeA.saveOnboardingResult(profile: profile, activityLevel: .highlyActive)

        // Simulate app restart by instantiating new store with same defaults
        let storeB = UserProfileStore(defaults: defaults)
        #expect(storeB.hasCompletedOnboarding == true)
        #expect(storeB.healthProfile?.age == 28)
        #expect(storeB.healthProfile?.weightKg == 75.0)
        #expect(storeB.activityLevel == .highlyActive)
        #expect(storeB.nutritionGoal?.targetCalories == storeA.nutritionGoal?.targetCalories)
    }

    @Test("Update profile recalculates nutrition goal dynamically")
    func updateProfileRecalculatesGoal() {
        let (store, _) = makeIsolatedStore()

        var profile = UserHealthProfile(
            age: 25,
            biologicalSex: .male,
            weightKg: 70.0,
            heightCm: 175.0,
            targetWeightKg: 70.0,
            goalCategory: .maintaining
        )
        store.saveOnboardingResult(profile: profile, activityLevel: .sedentary)
        let initialCalories = store.nutritionGoal?.targetCalories ?? 0

        // User edits goal in Profile to cutting
        profile.goalCategory = .cutting
        store.updateProfile(profile)

        let updatedCalories = store.nutritionGoal?.targetCalories ?? 0
        // Cutting should be ~500 kcal less than maintaining (subject to 1200 floor)
        #expect(updatedCalories < initialCalories)
    }
}
