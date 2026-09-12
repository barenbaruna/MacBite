//
//  CalorieCalendarViewModelTests.swift
//  CallBiteTests
//
//  Created by Codex on 10/09/26.
//

@testable import CallBite
import Foundation
import Testing

@Suite("CalorieCalendarViewModel Tests")
struct CalorieCalendarViewModelTests {
    @Test("Calendar uses a Monday-first grid")
    @MainActor
    func usesMondayFirstGrid() {
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let viewModel = CalorieCalendarViewModel(
            summaries: [:],
            selectedDate: today,
            today: today,
            calendar: calendar,
            historyMonthCount: 1
        )

        let september = viewModel.months[0]

        #expect(september.days[0].date == nil)
        #expect(september.days[1].dayNumber == 1)
        #expect(viewModel.weekdaySymbols.count == 7)
    }

    @Test("Only today and past dates can be selected")
    @MainActor
    func preventsFutureSelection() {
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let viewModel = CalorieCalendarViewModel(
            summaries: [:],
            selectedDate: today,
            today: today,
            calendar: calendar,
            historyMonthCount: 1
        )
        let september = viewModel.months[0]
        let todayCell = september.days.first(where: { $0.dayNumber == 10 })
        let futureCell = september.days.first(where: { $0.dayNumber == 11 })

        #expect(todayCell?.isSelectable == true)
        #expect(futureCell?.isSelectable == false)
        #expect(futureCell.flatMap(viewModel.select) == nil)
    }

    @Test("Calendar opens on the month containing today")
    @MainActor
    func opensOnCurrentMonth() {
        // Given
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let pastDate = calendar.date(byAdding: .month, value: -3, to: today) ?? .distantPast
        let viewModel = CalorieCalendarViewModel(
            summaries: [:],
            selectedDate: pastDate,
            today: today,
            calendar: calendar,
            historyMonthCount: 12
        )

        // When
        let expectedMonth = calendar.dateInterval(of: .month, for: today)?.start

        // Then
        #expect(viewModel.todayMonthID == expectedMonth)
    }

    @Test("Selecting a past date updates the dashboard and Today restores it")
    @MainActor
    func navigatesDashboardDates() {
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let pastDate = makeDate(day: 8, calendar: calendar)
        let todaySummary = DailySummary(
            dateString: "Hari Ini, 10 Sep 2026",
            targetCalories: 2_000,
            consumedCalories: 900
        )
        let pastSummary = DailySummary(
            dateString: "8 Sep 2026",
            targetCalories: 2_000,
            consumedCalories: 1_200
        )
        let viewModel = DashboardViewModel(
            dailySummary: todaySummary,
            selectedDate: today,
            today: today,
            dailySummaries: [today: todaySummary, pastDate: pastSummary],
            calendar: calendar
        )

        let didSelectPastDate = viewModel.selectDate(pastDate)

        #expect(didSelectPastDate)
        #expect(!viewModel.isShowingToday)
        #expect(viewModel.dailySummary == pastSummary)

        viewModel.returnToToday()

        #expect(viewModel.isShowingToday)
        #expect(viewModel.dailySummary == todaySummary)
    }

    @Test("A past date without entries opens an empty dashboard")
    @MainActor
    func opensEmptyPastDashboard() {
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let emptyDate = makeDate(day: 7, calendar: calendar)
        let todaySummary = DailySummary(
            targetCalories: 2_000,
            consumedCalories: 900
        )
        let viewModel = DashboardViewModel(
            dailySummary: todaySummary,
            selectedDate: today,
            today: today,
            dailySummaries: [today: todaySummary],
            calendar: calendar
        )

        viewModel.selectDate(emptyDate)

        #expect(viewModel.dailySummary.consumedCalories == 0)
        #expect(viewModel.dailySummary.targetCalories == 2_000)
        #expect(viewModel.ringProgress == 0)
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func makeDate(day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: day)) ?? .distantPast
    }
}
