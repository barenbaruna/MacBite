//
//  DashboardFoodHistoryTests.swift
//  CallBiteTests
//
//  Created by Codex on 10/09/26.
//

@testable import CallBite
import Foundation
import Testing

@Suite("Dashboard Food History Tests")
struct DashboardFoodHistoryTests {
    @Test("Food history follows the selected dashboard date")
    @MainActor
    func foodHistoryFollowsSelectedDate() {
        // Given
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let pastDate = makeDate(day: 9, calendar: calendar)
        let todayFood = FoodItem.dimsumMentai
        let pastFood = FoodItem.chickenRiceBowl
        let summary = DailySummary(targetCalories: 2_000, consumedCalories: 900)
        let viewModel = DashboardViewModel(
            dailySummary: summary,
            selectedDate: today,
            today: today,
            dailySummaries: [today: summary, pastDate: summary],
            dailyFoods: [today: [todayFood], pastDate: [pastFood]],
            calendar: calendar
        )

        // When
        viewModel.selectDate(pastDate)

        // Then
        #expect(viewModel.foodsForSelectedDate == [pastFood])

        // When
        viewModel.returnToToday()

        // Then
        #expect(viewModel.foodsForSelectedDate == [todayFood])
    }

    @Test("A day without foods has an empty food history")
    @MainActor
    func emptyDateHasNoFoods() {
        // Given
        let calendar = makeCalendar()
        let today = makeDate(day: 10, calendar: calendar)
        let emptyDate = makeDate(day: 8, calendar: calendar)
        let summary = DailySummary(targetCalories: 2_000, consumedCalories: 900)
        let viewModel = DashboardViewModel(
            dailySummary: summary,
            selectedDate: today,
            today: today,
            dailySummaries: [today: summary],
            dailyFoods: [today: [.dimsumMentai]],
            calendar: calendar
        )

        // When
        viewModel.selectDate(emptyDate)

        // Then
        #expect(viewModel.foodsForSelectedDate.isEmpty)
    }

    @Test("Saving a confirmed food adds it to the selected day")
    @MainActor
    func saveAddsFoodToHistory() {
        // Given
        let loggedFood = FoodItem.chickenRiceBowl
        let summary = DailySummary(targetCalories: 2_000, consumedCalories: 900)
        let viewModel = DashboardViewModel(dailySummary: summary)
        viewModel.resetAndOpenAddFood(with: loggedFood)

        // When
        viewModel.startSaveAnimation(reduceMotion: true)

        // Then
        #expect(viewModel.foodsForSelectedDate == [loggedFood])
        #expect(viewModel.dailySummary.consumedCalories == 1_580)
        #expect(viewModel.dailySummary.totalProtein == 62)
        #expect(viewModel.dailySummary.totalCarbs == 82)
        #expect(viewModel.dailySummary.totalFat == 35)
        #expect(viewModel.dailySummary.totalFiber == 106)
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
