//
//  WidgetSnapshotTests.swift
//  CallBiteTests
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

@testable import CallBite
import Foundation
import Testing

@Suite("Widget Snapshot Tests")
struct WidgetSnapshotTests {
    @Test("Widget snapshot persists in shared defaults")
    func snapshotRoundTrip() throws {
        // Given
        let suiteName = "WidgetSnapshotTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = CallBiteWidgetSnapshotStore(defaults: defaults)
        let snapshot = makeSnapshot()

        // When
        try store.save(snapshot)

        // Then
        #expect(store.load() == snapshot)
    }

    @Test("A snapshot from a previous day keeps goals and resets intake")
    func previousDayResetsIntake() throws {
        // Given
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let previousDay = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 12)))
        let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 13)))
        let snapshot = makeSnapshot(date: previousDay)

        // When
        let currentSnapshot = snapshot.valuesForToday(today, calendar: calendar)

        // Then
        #expect(currentSnapshot.consumedCalories == 0)
        #expect(currentSnapshot.proteinGrams == 0)
        #expect(currentSnapshot.carbsGrams == 0)
        #expect(currentSnapshot.fatGrams == 0)
        #expect(currentSnapshot.targetCalories == snapshot.targetCalories)
        #expect(currentSnapshot.targetProteinGrams == snapshot.targetProteinGrams)
    }

    @Test("Widget logging links map to their app routes")
    func loggingDeepLinksMapToRoutes() {
        // Given and When
        let cameraAction = CallBiteWidgetAction(url: CallBiteWidgetAction.camera.url)
        let manualAction = CallBiteWidgetAction(url: CallBiteWidgetAction.manual.url)

        // Then
        #expect(cameraAction?.appRoute == .foodCapture)
        #expect(manualAction?.appRoute == .manualLogging)
    }

    private func makeSnapshot(date: Date = .now) -> CallBiteWidgetSnapshot {
        CallBiteWidgetSnapshot(
            date: date,
            consumedCalories: 850,
            targetCalories: 2_000,
            proteinGrams: 48,
            targetProteinGrams: 100,
            carbsGrams: 96,
            targetCarbsGrams: 250,
            fatGrams: 28,
            targetFatGrams: 65,
            updatedAt: date
        )
    }
}
