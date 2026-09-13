//
//  OnboardingStep.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Navigation steps within the onboarding journey.
enum OnboardingStep: Int, CaseIterable, Hashable {
    case splash = 0
    case healthPrompt = 1
    case personalize = 2
    case lifestyle = 3
    case targetGoal = 4
}
