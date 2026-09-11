//
//  CalorieCalendarViewModel.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import Combine
import Foundation

@MainActor
final class CalorieCalendarViewModel: ObservableObject {
    @Published private(set) var selectedDate: Date
    @Published private(set) var months: [CalorieCalendarMonth]

    let weekdaySymbols: [String]

    private static let futureMonthCount = 1

    private let calendar: Calendar
    private let today: Date

    init(
        summaries: [Date: DailySummary],
        selectedDate: Date,
        today: Date,
        calendar: Calendar = .current,
        historyMonthCount: Int = 12
    ) {
        var mondayFirstCalendar = calendar
        mondayFirstCalendar.firstWeekday = 2

        let normalizedToday = mondayFirstCalendar.startOfDay(for: today)
        let normalizedSelectedDate = min(
            mondayFirstCalendar.startOfDay(for: selectedDate),
            normalizedToday
        )
        let normalizedSummaries = summaries.reduce(into: [:]) { result, entry in
            result[mondayFirstCalendar.startOfDay(for: entry.key)] = entry.value
        }

        self.calendar = mondayFirstCalendar
        self.today = normalizedToday
        self.selectedDate = normalizedSelectedDate
        self.weekdaySymbols = Self.makeWeekdaySymbols(calendar: mondayFirstCalendar)
        self.months = Self.makeMonths(
            summaries: normalizedSummaries,
            today: normalizedToday,
            calendar: mondayFirstCalendar,
            historyCount: max(1, historyMonthCount)
        )
    }

    var todayMonthID: Date {
        calendar.dateInterval(of: .month, for: today)?.start ?? today
    }

    var navigationTitle: String {
        today.formatted(
            .dateTime
                .month(.wide)
                .year()
                .locale(Locale(identifier: "id_ID"))
        )
    }

    func monthTitle(for month: CalorieCalendarMonth) -> String {
        month.startDate.formatted(
            .dateTime
                .month(.abbreviated)
                .locale(Locale(identifier: "id_ID"))
        )
    }

    func select(_ day: CalorieCalendarDay) -> Date? {
        guard day.isSelectable, let date = day.date else { return nil }
        selectedDate = date
        return date
    }

    func isSelected(_ day: CalorieCalendarDay) -> Bool {
        guard let date = day.date else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func isToday(_ day: CalorieCalendarDay) -> Bool {
        guard let date = day.date else { return false }
        return calendar.isDate(date, inSameDayAs: today)
    }

    func accessibilityLabel(for day: CalorieCalendarDay) -> String {
        guard let date = day.date else { return "" }

        let dateText = date.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
                .year()
                .locale(Locale(identifier: "id_ID"))
        )

        guard let summary = day.summary else {
            return "\(dateText), belum ada makanan tercatat"
        }

        return "\(dateText), \(summary.consumedCalories) dari \(summary.targetCalories) kalori"
    }

    private static func makeWeekdaySymbols(calendar: Calendar) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        return Array(symbols[firstIndex...] + symbols[..<firstIndex])
    }

    private static func makeMonths(
        summaries: [Date: DailySummary],
        today: Date,
        calendar: Calendar,
        historyCount: Int
    ) -> [CalorieCalendarMonth] {
        guard let currentMonth = calendar.dateInterval(of: .month, for: today)?.start else {
            return []
        }

        let firstMonthOffset = -(historyCount - 1)
        return (firstMonthOffset...futureMonthCount).compactMap { offset in
            guard let monthStart = calendar.date(
                byAdding: .month,
                value: offset,
                to: currentMonth
            ) else {
                return nil
            }

            return makeMonth(
                startDate: monthStart,
                summaries: summaries,
                today: today,
                calendar: calendar
            )
        }
    }

    private static func makeMonth(
        startDate: Date,
        summaries: [Date: DailySummary],
        today: Date,
        calendar: Calendar
    ) -> CalorieCalendarMonth? {
        guard let dayRange = calendar.range(of: .day, in: .month, for: startDate) else {
            return nil
        }

        let weekday = calendar.component(.weekday, from: startDate)
        let leadingPlaceholderCount = (weekday - calendar.firstWeekday + 7) % 7
        var days: [CalorieCalendarDay] = []

        for position in 0..<leadingPlaceholderCount {
            days.append(
                CalorieCalendarDay(
                    id: "\(startDate.timeIntervalSinceReferenceDate)-placeholder-\(position)",
                    date: nil,
                    dayNumber: nil,
                    summary: nil,
                    isSelectable: false
                )
            )
        }

        for dayNumber in dayRange {
            guard let date = calendar.date(
                byAdding: .day,
                value: dayNumber - 1,
                to: startDate
            ) else {
                continue
            }

            let normalizedDate = calendar.startOfDay(for: date)
            days.append(
                CalorieCalendarDay(
                    id: "\(normalizedDate.timeIntervalSinceReferenceDate)",
                    date: normalizedDate,
                    dayNumber: dayNumber,
                    summary: summaries[normalizedDate],
                    isSelectable: normalizedDate <= today
                )
            )
        }

        return CalorieCalendarMonth(
            id: startDate,
            startDate: startDate,
            days: days
        )
    }
}
