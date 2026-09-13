//
//  ProfileFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import SwiftUI

/// Factory for assembling the Profile feature view with required dependencies.
enum ProfileFactory {
    @MainActor
    static func makeView(
        initialProfile: UserHealthProfile? = nil,
        onSave: ((UserHealthProfile) -> Void)? = nil
    ) -> some View {
        let profile = initialProfile ?? UserProfileStore.shared.healthProfile ?? UserHealthProfile(
            age: 22,
            biologicalSex: .preferNotToSay,
            weightKg: 56.0,
            heightCm: 162.0
        )
        let viewModel = ProfileViewModel(initialProfile: profile, onSave: onSave)
        return ProfileView(viewModel: viewModel)
    }
}
