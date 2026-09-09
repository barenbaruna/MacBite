//
//  FoodItem.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

struct FoodItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var mealType: String
    var dateString: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var photoSystemName: String

    init(
        id: UUID = UUID(),
        name: String,
        mealType: String,
        dateString: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fat: Int,
        photoSystemName: String = "photo"
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.dateString = dateString
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.photoSystemName = photoSystemName
    }
    
    static let dimsumMentai = FoodItem(
        name: "Dimsum Mentai",
        mealType: "1st Meal",
        dateString: "6 September 2026",
        calories: 475,
        protein: 14,
        carbs: 81,
        fat: 12,
        photoSystemName: "fork.knife"
    )

    static let chickenRiceBowl = FoodItem(
        name: "Grilled Chicken Bowl",
        mealType: "Lunch",
        dateString: "6 September 2026",
        calories: 680,
        protein: 48,
        carbs: 65,
        fat: 18,
        photoSystemName: "takeoutbag.and.cup.and.straw.fill"
    )

    static let oatmealBerry = FoodItem(
        name: "Oatmeal Berry Delight",
        mealType: "Breakfast",
        dateString: "6 September 2026",
        calories: 320,
        protein: 12,
        carbs: 55,
        fat: 6,
        photoSystemName: "cup.and.saucer.fill"
    )

    static let allPresets: [FoodItem] = [dimsumMentai, chickenRiceBowl, oatmealBerry]
}
