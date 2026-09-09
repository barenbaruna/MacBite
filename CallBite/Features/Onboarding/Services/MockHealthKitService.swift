//
//  MockHealthKitService.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Foundation

final class MockHealthKitService: HealthServiceProtocol {
    func requestAuthorization() async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000)
        return true
    }

    func fetchProfile() async throws -> UserHealthProfile {
        return UserHealthProfile(
            age: 22,
            biologicalSex: .male,
            weightKg: 56,
            heightCm: 162
        )
    }
}
