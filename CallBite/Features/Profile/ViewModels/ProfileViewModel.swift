//
//  ProfileViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 10/09/26.
//

import Combine
import Foundation

/// Health profile metrics editable by the user.
enum ProfileField: String, Identifiable, Sendable {
    case age
    case sex
    case weight
    case height

    var id: String { rawValue }

    var title: String {
        switch self {
        case .age: return "Age"
        case .sex: return "Sex"
        case .weight: return "Weight"
        case .height: return "Height"
        }
    }
}

/// ViewModel managing user health profile attributes and save operations.
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var age: Int
    @Published var biologicalSex: BiologicalSex
    @Published var weightKg: Double
    @Published var heightCm: Double
    @Published var targetWeightKg: Double?
    @Published var goalCategory: GoalCategory?

    @Published var isShowingChangeGoal = false
    @Published var activeFieldForEdit: ProfileField?

    private let onSave: ((UserHealthProfile) -> Void)?

    init(
        initialProfile: UserHealthProfile = UserHealthProfile(
            age: 22,
            biologicalSex: .male,
            weightKg: 56.0,
            heightCm: 162.0
        ),
        onSave: ((UserHealthProfile) -> Void)? = nil
    ) {
        self.age = initialProfile.age > 0 ? initialProfile.age : 22
        self.biologicalSex = initialProfile.biologicalSex != .notSet ? initialProfile.biologicalSex : .male
        self.weightKg = initialProfile.weightKg > 0 ? initialProfile.weightKg : 56.0
        self.heightCm = initialProfile.heightCm > 0 ? initialProfile.heightCm : 162.0
        self.targetWeightKg = initialProfile.targetWeightKg
        self.goalCategory = initialProfile.goalCategory
        self.onSave = onSave
    }

    var currentProfile: UserHealthProfile {
        UserHealthProfile(
            age: age,
            biologicalSex: biologicalSex,
            weightKg: weightKg,
            heightCm: heightCm,
            targetWeightKg: targetWeightKg,
            goalCategory: goalCategory
        )
    }

    var goalSummaryText: String? {
        guard let target = targetWeightKg, let category = goalCategory else { return nil }
        return "\(category.displayName) (\(Int(target.rounded()))kg)"
    }

    func updateGoal(targetWeight: Double, category: GoalCategory) {
        self.targetWeightKg = targetWeight
        self.goalCategory = category
    }

    func saveProfile() {
        AppHaptics.primaryAction()
        onSave?(currentProfile)
    }
}
