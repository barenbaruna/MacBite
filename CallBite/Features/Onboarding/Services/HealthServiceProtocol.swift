//
//  HealthServiceProtocol.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Foundation

protocol HealthServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func fetchProfile() async throws -> UserHealthProfile
}
