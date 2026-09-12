//
//  MealStorePersistenceTests.swift
//  CallBiteTests
//
//  Created by Codex on 12/09/26.
//

@testable import CallBite
import Foundation
import Testing

@Suite("Meal Store Persistence Tests")
struct MealStorePersistenceTests {
    @Test("SwiftDataMealStore saves, fetches, and updates meals")
    @MainActor
    func storeSavesAndFetchesMeals() throws {
        let calendar = makeCalendar()
        let store = SwiftDataMealStore(inMemory: true, calendar: calendar)
        let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 12))!

        let food = FoodItem(
            name: "Avocado Toast",
            mealType: "Breakfast",
            dateString: "12 September 2026",
            calories: 320,
            protein: 8,
            carbs: 28,
            fat: 18,
            fiber: 6
        )

        // Save
        try store.saveMeal(food, for: date)
        let fetched = try store.fetchMeals(for: date)
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Avocado Toast")
        #expect(fetched.first?.calories == 320)

        // Update
        var updatedFood = food
        updatedFood.calories = 380
        try store.saveMeal(updatedFood, for: date)

        let reFetched = try store.fetchMeals(for: date)
        #expect(reFetched.count == 1)
        #expect(reFetched.first?.calories == 380)

        // Delete
        try store.deleteMeal(id: food.id)
        let afterDelete = try store.fetchMeals(for: date)
        #expect(afterDelete.isEmpty)
    }

    @Test("DashboardViewModel restores logged meals across simulated app relaunch")
    @MainActor
    func dashboardRestoresMealsAcrossRelaunch() {
        let calendar = makeCalendar()
        let store = SwiftDataMealStore(inMemory: true, calendar: calendar)
        let today = calendar.date(from: DateComponents(year: 2026, month: 9, day: 12))!

        let summary = DailySummary(
            targetCalories: 2000,
            consumedCalories: 0,
            targetCarbs: 250,
            targetProtein: 100,
            targetFat: 65,
            targetFiber: 30,
            totalCarbs: 0,
            totalProtein: 0,
            totalFat: 0,
            totalFiber: 0
        )

        // Session 1: User logs a meal
        let sessionOneVM = DashboardViewModel(
            dailySummary: summary,
            selectedDate: today,
            today: today,
            calendar: calendar,
            mealStore: store
        )

        let lunch = FoodItem(
            name: "Salmon Salad",
            mealType: "Lunch",
            dateString: "12 September 2026",
            calories: 550,
            protein: 42,
            carbs: 12,
            fat: 26,
            fiber: 5
        )

        sessionOneVM.resetAndOpenAddFood(with: lunch)
        sessionOneVM.startSaveAnimation(reduceMotion: true)

        #expect(sessionOneVM.foodsForSelectedDate.count == 1)
        #expect(sessionOneVM.dailySummary.consumedCalories == 550)
        #expect(abs(sessionOneVM.ringProgress - 0.275) < 0.001)

        // Session 2: User closes and re-opens app (simulated by new ViewModel reading same store)
        let sessionTwoVM = DashboardViewModel(
            dailySummary: summary,
            selectedDate: today,
            today: today,
            calendar: calendar,
            mealStore: store
        )

        #expect(sessionTwoVM.foodsForSelectedDate.count == 1)
        #expect(sessionTwoVM.foodsForSelectedDate.first?.name == "Salmon Salad")
        #expect(sessionTwoVM.dailySummary.consumedCalories == 550)
        #expect(sessionTwoVM.dailySummary.totalProtein == 42)
        #expect(sessionTwoVM.dailySummary.totalCarbs == 12)
        #expect(sessionTwoVM.dailySummary.totalFat == 26)
        #expect(sessionTwoVM.dailySummary.totalFiber == 5)
        #expect(abs(sessionTwoVM.ringProgress - 0.275) < 0.001)
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }
}
