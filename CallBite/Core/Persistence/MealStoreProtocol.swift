//
//  MealStoreProtocol.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import Foundation

/// Defines persistence operations for logged meal entries.
@MainActor
public protocol MealStoreProtocol: AnyObject {
    /// Fetches all logged food items for a specific date.
    func fetchMeals(for date: Date) throws -> [FoodItem]

    /// Fetches all logged food items grouped by start of day.
    func fetchAllMeals() throws -> [Date: [FoodItem]]

    /// Saves or updates a food item for a given date.
    func saveMeal(_ food: FoodItem, for date: Date) throws

    /// Deletes a logged food item by its identifier.
    func deleteMeal(id: UUID) throws

    /// Deletes all stored meal entries.
    func deleteAllMeals() throws
}
