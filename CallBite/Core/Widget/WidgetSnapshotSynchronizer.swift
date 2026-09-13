//
//  WidgetSnapshotSynchronizer.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import Foundation
import WidgetKit

/// Publishes the current day's nutrition totals to the shared widget container.
@MainActor
public struct WidgetSnapshotSynchronizer {
    private let store: CallBiteWidgetSnapshotStore?
    private let calendar: Calendar

    public static func live() -> Self {
        WidgetSnapshotSynchronizer(
            store: CallBiteWidgetSnapshotStore.makeDefault(),
            calendar: .current
        )
    }

    init(store: CallBiteWidgetSnapshotStore?, calendar: Calendar) {
        self.store = store
        self.calendar = calendar
    }

    public func synchronize(_ summary: DailySummary, for date: Date, today: Date = .now) {
        guard calendar.isDate(date, inSameDayAs: today), let store else { return }

        let snapshot = CallBiteWidgetSnapshot(
            date: date,
            consumedCalories: summary.consumedCalories,
            targetCalories: summary.targetCalories,
            proteinGrams: summary.totalProtein,
            targetProteinGrams: summary.targetProtein,
            carbsGrams: summary.totalCarbs,
            targetCarbsGrams: summary.targetCarbs,
            fatGrams: summary.totalFat,
            targetFatGrams: summary.targetFat,
            updatedAt: today
        )

        do {
            try store.save(snapshot)
            WidgetCenter.shared.reloadTimelines(ofKind: CallBiteWidgetConfiguration.kind)
        } catch {
            // Widget synchronization is best-effort and must not block meal persistence.
            #if DEBUG
            print("[WidgetSnapshotSynchronizer] Unable to save widget snapshot: \(error)")
            #endif
        }
    }
}
