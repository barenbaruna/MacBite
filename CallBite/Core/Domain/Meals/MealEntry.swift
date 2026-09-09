//
//  MealEntry.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Foundation

/// Meal yang sudah dikonfirmasi dan disimpan ke riwayat pengguna
struct MealEntry: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let items: [FoodItem]
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let loggedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        items: [FoodItem] = [],
        totalCalories: Double = 0,
        totalProtein: Double = 0,
        totalCarbs: Double = 0,
        totalFat: Double = 0,
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.loggedAt = loggedAt
    }
}
