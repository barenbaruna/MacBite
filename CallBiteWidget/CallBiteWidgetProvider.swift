//
//  CallBiteWidgetProvider.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import WidgetKit

struct CallBiteWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CallBiteWidgetEntry {
        CallBiteWidgetEntry(date: .now, snapshot: sampleSnapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (CallBiteWidgetEntry) -> Void) {
        completion(entry(for: .now, usePlaceholder: context.isPreview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CallBiteWidgetEntry>) -> Void) {
        let now = Date.now
        let entry = entry(for: now, usePlaceholder: false)
        completion(Timeline(entries: [entry], policy: .after(nextDay(after: now))))
    }

    private func entry(for date: Date, usePlaceholder: Bool) -> CallBiteWidgetEntry {
        let snapshot: CallBiteWidgetSnapshot
        if usePlaceholder {
            snapshot = sampleSnapshot
        } else {
            snapshot = CallBiteWidgetSnapshotStore.makeDefault()?.load()?.valuesForToday(date)
                ?? .empty(for: date)
        }

        return CallBiteWidgetEntry(date: date, snapshot: snapshot)
    }

    private func nextDay(after date: Date) -> Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfToday)
            ?? date.addingTimeInterval(3_600)
    }

    private var sampleSnapshot: CallBiteWidgetSnapshot {
        CallBiteWidgetSnapshot(
            date: .now,
            consumedCalories: 1_240,
            targetCalories: 2_000,
            proteinGrams: 72,
            targetProteinGrams: 100,
            carbsGrams: 138,
            targetCarbsGrams: 250,
            fatGrams: 41,
            targetFatGrams: 65,
            updatedAt: .now
        )
    }
}
