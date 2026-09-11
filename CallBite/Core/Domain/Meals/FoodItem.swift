//
//  FoodItem.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Pure domain model representing a logged food item and its macronutrient profile.
public struct FoodItem: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var mealType: String
    public var dateString: String
    public var calories: Int
    public var protein: Int
    public var carbs: Int
    public var fat: Int
    public var fiber: Int
    public var photoSystemName: String
    /// Actual captured/picked photo, encoded as JPEG. `nil` for entries without
    /// a real photo (e.g. manual logging) — the SF Symbol fallback
    /// (`photoSystemName`) is used for display in that case.
    public var photoData: Data?

    public init(
        id: UUID = UUID(),
        name: String,
        mealType: String,
        dateString: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fat: Int,
        fiber: Int = 0,
        photoSystemName: String = "fork.knife",
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.dateString = dateString
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.photoSystemName = photoSystemName
        self.photoData = photoData
    }
}

// MARK: - Mock Presets
public extension FoodItem {
    static let dimsumMentai = FoodItem(
        name: "Dimsum Mentai",
        mealType: "1st Meal",
        dateString: "4 September 2026",
        calories: 475,
        protein: 14,
        carbs: 81,
        fat: 12,
        fiber: 4,
        photoSystemName: "fork.knife"
    )

    static let chickenRiceBowl = FoodItem(
        name: "Grilled Chicken Bowl",
        mealType: "Lunch",
        dateString: "4 September 2026",
        calories: 680,
        protein: 48,
        carbs: 65,
        fat: 18,
        fiber: 6,
        photoSystemName: "takeoutbag.and.cup.and.straw.fill"
    )

    static let oatmealBerry = FoodItem(
        name: "Oatmeal Berry Delight",
        mealType: "Breakfast",
        dateString: "4 September 2026",
        calories: 320,
        protein: 12,
        carbs: 55,
        fat: 6,
        fiber: 8,
        photoSystemName: "cup.and.saucer.fill"
    )

    static let allPresets: [FoodItem] = [dimsumMentai, chickenRiceBowl, oatmealBerry]
}
