//
//  HealthServiceProtocol.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Protokol kontrak layanan sinkronisasi data Apple Health
protocol HealthServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func fetchProfile() async throws -> UserHealthProfile
}
