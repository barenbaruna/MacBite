//
//  HealthKitClient.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Foundation
import HealthKit

/// Native HealthKit client implementation for reading profile metrics and writing dietary nutrition data.
final class HealthKitClient: HealthServiceProtocol, @unchecked Sendable {

    static let shared = HealthKitClient()

    private let healthStore = HKHealthStore()

    // MARK: - HealthKit Sample Types

    /// Sample types written (shared) by MacBite to Apple Health (dietary intake only).
    static let shareTypes: Set<HKSampleType> = [
        HKQuantityType(.dietaryEnergyConsumed),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietaryFatTotal)
    ]

    /// Object types read from Apple Health for computing nutrition targets and progress.
    static let readTypes: Set<HKObjectType> = [
        HKQuantityType(.bodyMass),
        HKQuantityType(.height),
        HKCharacteristicType(.dateOfBirth),
        HKCharacteristicType(.biologicalSex),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.basalEnergyBurned),
        HKQuantityType(.dietaryEnergyConsumed),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietaryFatTotal)
    ]

    init() {}

    // MARK: - HealthServiceProtocol

    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }

        try await healthStore.requestAuthorization(
            toShare: Self.shareTypes,
            read: Self.readTypes
        )
        return true
    }

    func fetchProfile() async throws -> UserHealthProfile {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .empty
        }

        let weightKg = await fetchLatestWeight()
        let heightCm = await fetchLatestHeight()
        let age = fetchAge()
        let sex = fetchBiologicalSex()

        return UserHealthProfile(
            age: age,
            biologicalSex: sex,
            weightKg: weightKg,
            heightCm: heightCm
        )
    }

    // MARK: - Queries Using Async Descriptors

    private func fetchLatestWeight() async -> Double {
        let weightType = HKQuantityType(.bodyMass)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: weightType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)
            if let sample = results.first {
                return sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            }
        } catch {
            return 0.0
        }
        return 0.0
    }

    private func fetchLatestHeight() async -> Double {
        let heightType = HKQuantityType(.height)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: heightType)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)
            if let sample = results.first {
                return sample.quantity.doubleValue(for: .meterUnit(with: .centi))
            }
        } catch {
            return 0.0
        }
        return 0.0
    }

    private func fetchAge() -> Int {
        do {
            let components = try healthStore.dateOfBirthComponents()
            if let birthDate = Calendar.current.date(from: components) {
                let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
                return ageComponents.year ?? 0
            }
        } catch {
            return 0
        }
        return 0
    }

    private func fetchBiologicalSex() -> BiologicalSex {
        do {
            let sexObject = try healthStore.biologicalSex()
            switch sexObject.biologicalSex {
            case .female:
                return .female
            case .male:
                return .male
            case .other:
                return .preferNotToSay
            case .notSet:
                #if DEBUG
                print("[HealthKitClient] BiologicalSex is .notSet (unconfigured or permission denied)")
                #endif
                return .notSet
            @unknown default:
                return .notSet
            }
        } catch let hkError as HKError {
            #if DEBUG
            print("[HealthKitClient] HKError biologicalSex: \(hkError.localizedDescription)")
            #endif
            return .notSet
        } catch {
            #if DEBUG
            print("[HealthKitClient] Unexpected error fetching biologicalSex: \(error.localizedDescription)")
            #endif
            return .notSet
        }
    }
}
