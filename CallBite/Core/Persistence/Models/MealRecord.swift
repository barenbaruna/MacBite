//
//  MealRecord.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Foundation
import SwiftData

/// SwiftData persistence model representing a stored meal entry.
/// Separated from the domain model `FoodItem` following clean architecture principles.
@Model
public final class MealRecord {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var mealType: String
    public var date: Date
    public var dateString: String
    public var calories: Int
    public var protein: Int
    public var carbs: Int
    public var fat: Int
    public var fiber: Int
    public var photoSystemName: String
    public var photoAssetName: String?
    @Attribute(.externalStorage) public var photoData: Data?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        mealType: String,
        date: Date,
        dateString: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fat: Int,
        fiber: Int = 0,
        photoSystemName: String = "fork.knife",
        photoAssetName: String? = nil,
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.date = date
        self.dateString = dateString
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.photoSystemName = photoSystemName
        self.photoAssetName = photoAssetName
        self.photoData = photoData
        self.createdAt = createdAt
    }

    public convenience init(from food: FoodItem, date: Date) {
        self.init(
            id: food.id,
            name: food.name,
            mealType: food.mealType,
            date: date,
            dateString: food.dateString,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            fiber: food.fiber,
            photoSystemName: food.photoSystemName,
            photoAssetName: food.photoAssetName,
            photoData: food.photoData
        )
    }

    public func toFoodItem() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            mealType: mealType,
            dateString: dateString,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            photoSystemName: photoSystemName,
            photoAssetName: photoAssetName,
            photoData: photoData
        )
    }
}
