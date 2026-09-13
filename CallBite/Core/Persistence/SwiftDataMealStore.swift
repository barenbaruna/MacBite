//
//  SwiftDataMealStore.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Foundation
import SwiftData

/// SwiftData implementation of `MealStoreProtocol` providing persistent meal storage across app launches.
@MainActor
public final class SwiftDataMealStore: MealStoreProtocol {
    public static let shared = SwiftDataMealStore()

    public static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        ProcessInfo.processInfo.environment["XCTestBundlePath"] != nil ||
        ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil ||
        NSClassFromString("XCTestCase") != nil
    }

    public static func defaultStore() -> MealStoreProtocol {
        if isRunningTests {
            return SwiftDataMealStore(inMemory: true)
        }
        return shared
    }

    private let container: ModelContainer
    private let context: ModelContext
    private let calendar: Calendar

    public init(inMemory: Bool = false, calendar: Calendar = .current) {
        self.calendar = calendar
        let schema = Schema([MealRecord.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        if let container = try? ModelContainer(for: schema, configurations: [configuration]) {
            self.container = container
            self.context = container.mainContext
        } else {
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            do {
                self.container = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
                self.context = self.container.mainContext
            } catch {
                fatalError("Failed to initialize SwiftData container: \(error)")
            }
        }
    }

    public init(container: ModelContainer, calendar: Calendar = .current) {
        self.container = container
        self.context = container.mainContext
        self.calendar = calendar
    }

    public func fetchMeals(for date: Date) throws -> [FoodItem] {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let descriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { record in
                record.date >= startOfDay && record.date < endOfDay
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        let records = try context.fetch(descriptor)
        return records.map { $0.toFoodItem() }
    }

    public func fetchAllMeals() throws -> [Date: [FoodItem]] {
        let descriptor = FetchDescriptor<MealRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        let records = try context.fetch(descriptor)
        var result: [Date: [FoodItem]] = [:]

        for record in records {
            let normalizedDate = calendar.startOfDay(for: record.date)
            result[normalizedDate, default: []].append(record.toFoodItem())
        }

        return result
    }

    public func saveMeal(_ food: FoodItem, for date: Date) throws {
        let normalizedDate = calendar.startOfDay(for: date)
        let foodId = food.id

        let descriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { record in
                record.id == foodId
            }
        )

        let matches = try context.fetch(descriptor)
        if let existing = matches.first {
            existing.name = food.name
            existing.mealType = food.mealType
            existing.date = normalizedDate
            existing.dateString = food.dateString
            existing.calories = food.calories
            existing.protein = food.protein
            existing.carbs = food.carbs
            existing.fat = food.fat
            existing.fiber = food.fiber
            existing.photoSystemName = food.photoSystemName
            existing.photoAssetName = food.photoAssetName
            existing.photoData = food.photoData
        } else {
            let record = MealRecord(from: food, date: normalizedDate)
            context.insert(record)
        }

        try context.save()
    }

    public func deleteMeal(id: UUID) throws {
        let targetId = id
        let descriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { record in
                record.id == targetId
            }
        )

        let matches = try context.fetch(descriptor)
        for record in matches {
            context.delete(record)
        }

        try context.save()
    }

    public func deleteAllMeals() throws {
        let descriptor = FetchDescriptor<MealRecord>()
        let records = try context.fetch(descriptor)
        for record in records {
            context.delete(record)
        }
        try context.save()
    }
}
