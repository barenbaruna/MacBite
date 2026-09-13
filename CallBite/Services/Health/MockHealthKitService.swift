//
//  MockHealthKitService.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Mock implementation of Apple Health service for previews and unit tests.
final class MockHealthKitService: HealthServiceProtocol {
    var shouldGrantAccess: Bool
    var mockProfile: UserHealthProfile

    init(
        shouldGrantAccess: Bool = true,
        mockProfile: UserHealthProfile? = nil
    ) {
        self.shouldGrantAccess = shouldGrantAccess
        self.mockProfile = mockProfile ?? UserHealthProfile(
            age: 22,
            biologicalSex: .male,
            weightKg: 56,
            heightCm: 162
        )
    }

    func requestAuthorization() async throws -> Bool {
        shouldGrantAccess
    }

    func fetchProfile() async throws -> UserHealthProfile {
        if shouldGrantAccess {
            return mockProfile
        } else {
            return .empty
        }
    }
}
