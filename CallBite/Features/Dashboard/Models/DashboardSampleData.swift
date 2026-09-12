//
//  DashboardSampleData.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 10/09/26.
//

import Foundation

enum DashboardSampleData {
    private static let historyDayCount = 90
    private static let noEntryInterval = 6
    private static let progressSamples = [0.24, 0.43, 0.62, 0.79, 0.96, 1.08, 1.22]

    static func makeHistory(
        endingOn today: Date,
        currentSummary: DailySummary,
        calendar: Calendar = .current
    ) -> [Date: DailySummary] {
        let normalizedToday = calendar.startOfDay(for: today)
        var history: [Date: DailySummary] = [:]

        for offset in 0..<historyDayCount {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: normalizedToday) else {
                continue
            }

            if offset > 0 && offset.isMultiple(of: noEntryInterval) {
                continue
            }

            let progress = progressSamples[offset % progressSamples.count]
            let targetCalories = currentSummary.targetCalories
            let consumedCalories = Int((Double(targetCalories) * progress).rounded())

            history[date] = DailySummary(
                dateString: displayDate(for: date, today: normalizedToday, calendar: calendar),
                targetCalories: targetCalories,
                consumedCalories: consumedCalories,
                targetCarbs: currentSummary.targetCarbs,
                targetProtein: currentSummary.targetProtein,
                targetFat: currentSummary.targetFat,
                targetFiber: currentSummary.targetFiber,
                totalCarbs: Int((Double(currentSummary.totalCarbs) * progress).rounded()),
                totalProtein: Int((Double(currentSummary.totalProtein) * progress).rounded()),
                totalFat: Int((Double(currentSummary.totalFat) * progress).rounded()),
                totalFiber: Int((Double(currentSummary.totalFiber) * progress).rounded()),
                streakDays: max(0, currentSummary.streakDays - offset)
            )
        }

        var todaySummary = currentSummary
        todaySummary.dateString = displayDate(
            for: normalizedToday,
            today: normalizedToday,
            calendar: calendar
        )
        history[normalizedToday] = todaySummary

        return history
    }

    static func displayDate(
        for date: Date,
        today: Date,
        calendar: Calendar
    ) -> String {
        let formattedDate = date.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .year()
                .locale(Locale(identifier: "en_GB"))
        )

        if calendar.isDate(date, inSameDayAs: today) {
            return "Today, \(formattedDate)"
        }

        return formattedDate
    }

    static func makeFoodHistory(
        summaries: [Date: DailySummary],
        endingOn today: Date,
        calendar: Calendar = .current
    ) -> [Date: [FoodItem]] {
        let normalizedToday = calendar.startOfDay(for: today)

        return summaries.reduce(into: [:]) { history, entry in
            let date = calendar.startOfDay(for: entry.key)
            let daysAgo = calendar.dateComponents([.day], from: date, to: normalizedToday).day ?? 0
            let sampleFoods = foods(for: entry.value.dateString)
            let foodCount = calendar.isDate(date, inSameDayAs: normalizedToday)
                ? sampleFoods.count
                : (daysAgo % sampleFoods.count) + 1
            history[date] = Array(sampleFoods.prefix(foodCount))
        }
    }

    private static func foods(for dateString: String) -> [FoodItem] {
        [
            FoodItem(
                name: "Dimsum Mentai",
                mealType: "Breakfast",
                dateString: dateString,
                calories: 475,
                protein: 14,
                carbs: 81,
                fat: 12,
                fiber: 4,
                photoAssetName: "FoodDemoOne"
            ),
            FoodItem(
                name: "Roti Bakar",
                mealType: "Breakfast",
                dateString: dateString,
                calories: 320,
                protein: 10,
                carbs: 48,
                fat: 9,
                fiber: 3
            ),
            FoodItem(
                name: "Batagor",
                mealType: "Lunch",
                dateString: dateString,
                calories: 410,
                protein: 18,
                carbs: 42,
                fat: 19,
                fiber: 3,
                photoAssetName: "FoodDemoTwo"
            )
        ]
    }
}
