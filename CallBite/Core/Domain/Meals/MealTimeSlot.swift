//
//  MealTimeSlot.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 11/09/26.
//

import Foundation

/// Defines time-based meal categories and associated greetings for food logging.
public enum MealTimeSlot: String, CaseIterable, Identifiable, Sendable, Equatable, Hashable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snackLateNight = "Snack / Late Night"

    public var id: String { rawValue }

    public var displayName: String { rawValue }

    public var greetingMessage: String {
        switch self {
        case .breakfast:
            return "Good morning! Logging Breakfast"
        case .lunch:
            return "Midday boost! Logging Lunch"
        case .dinner:
            return "Good evening! Logging Dinner"
        case .snackLateNight:
            return "Late night bite! Logging Snack"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .breakfast:
            return "sun.max.fill"
        case .lunch:
            return "bolt.fill"
        case .dinner:
            return "sunset.fill"
        case .snackLateNight:
            return "moon.stars.fill"
        }
    }

    /// Resolves the corresponding `MealTimeSlot` for a given time of day.
    ///
    /// - 05:00 ..< 11:00 -> Breakfast
    /// - 11:00 ..< 16:00 -> Lunch
    /// - 16:00 ..< 21:00 -> Dinner
    /// - 21:00 ..< 05:00 -> Snack / Late Night
    public static func slot(for date: Date = Date(), calendar: Calendar = .current) -> MealTimeSlot {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<21:
            return .dinner
        default:
            return .snackLateNight
        }
    }

    /// Looks up a slot matching a meal type string, or resolves based on current date.
    public static func slot(forMealType mealType: String, fallbackDate: Date = Date()) -> MealTimeSlot {
        if let direct = MealTimeSlot(rawValue: mealType) {
            return direct
        }
        if mealType == "Snack" {
            return .snackLateNight
        }
        return slot(for: fallbackDate)
    }
}
