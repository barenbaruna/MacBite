//
//  UserProfileStore.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import Foundation

/// Lightweight persistence layer for the user's health profile, activity level,
/// and onboarding completion state.
///
/// Uses `UserDefaults` with JSON-encoded `Codable` structs — consistent with
/// the existing `UserDefaultsCameraGuideStore` pattern and appropriate for
/// a single lightweight profile (not relational data).
final class UserProfileStore: @unchecked Sendable {

    // MARK: - Singleton

    static let shared = UserProfileStore()

    // MARK: - Keys

    private enum Keys {
        static let healthProfile = "callbite.user.healthProfile"
        static let activityLevel = "callbite.user.activityLevel"
        static let hasCompletedOnboarding = "callbite.user.hasCompletedOnboarding"
    }

    // MARK: - Dependencies

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Onboarding Flag

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Health Profile

    var healthProfile: UserHealthProfile? {
        get {
            guard let data = defaults.data(forKey: Keys.healthProfile) else { return nil }
            return try? decoder.decode(UserHealthProfile.self, from: data)
        }
        set {
            if let newValue, let data = try? encoder.encode(newValue) {
                defaults.set(data, forKey: Keys.healthProfile)
            } else {
                defaults.removeObject(forKey: Keys.healthProfile)
            }
        }
    }

    // MARK: - Activity Level

    var activityLevel: ActivityLevel? {
        get {
            guard let data = defaults.data(forKey: Keys.activityLevel) else { return nil }
            return try? decoder.decode(ActivityLevel.self, from: data)
        }
        set {
            if let newValue, let data = try? encoder.encode(newValue) {
                defaults.set(data, forKey: Keys.activityLevel)
            } else {
                defaults.removeObject(forKey: Keys.activityLevel)
            }
        }
    }

    // MARK: - Computed Nutrition Goal

    /// Computes the user's `NutritionGoal` from the stored profile + activity level.
    /// Returns `nil` if either is missing.
    var nutritionGoal: NutritionGoal? {
        guard let profile = healthProfile else { return nil }
        let activity = activityLevel ?? .moderatelyActive
        let category = profile.goalCategory ?? .maintaining

        let bmr = GoalCalculator.calculateBMR(profile: profile)
        let tdee = GoalCalculator.calculateTDEE(bmr: bmr, activityLevel: activity)
        let calories = GoalCalculator.calculateDailyCalorieTarget(tdee: tdee, category: category)
        return GoalCalculator.calculateMacronutrients(dailyCalories: calories)
    }

    // MARK: - Convenience Save

    /// Persists the full onboarding result atomically and marks onboarding as complete.
    func saveOnboardingResult(
        profile: UserHealthProfile,
        activityLevel: ActivityLevel
    ) {
        self.healthProfile = profile
        self.activityLevel = activityLevel
        self.hasCompletedOnboarding = true

        #if DEBUG
        print("[UserProfileStore] Onboarding saved — profile: \(profile), activity: \(activityLevel.rawValue)")
        if let goal = nutritionGoal {
            print(
                "[UserProfileStore] Computed goal: \(goal.targetCalories) kcal, " +
                "P\(goal.targetProteinGrams)g, C\(goal.targetCarbsGrams)g, F\(goal.targetFatGrams)g"
            )
        }
        #endif
    }

    /// Updates profile and recalculates targets (used from Profile screen edits).
    func updateProfile(_ profile: UserHealthProfile) {
        self.healthProfile = profile

        #if DEBUG
        print("[UserProfileStore] Profile updated — \(profile)")
        if let goal = nutritionGoal {
            print("[UserProfileStore] Recalculated goal: \(goal.targetCalories) kcal")
        }
        #endif
    }

    // MARK: - Reset (Testing)

    #if DEBUG
    func reset() {
        defaults.removeObject(forKey: Keys.healthProfile)
        defaults.removeObject(forKey: Keys.activityLevel)
        defaults.set(false, forKey: Keys.hasCompletedOnboarding)
    }
    #endif
}
