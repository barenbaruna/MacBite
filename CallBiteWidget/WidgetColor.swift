//
//  WidgetColor.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

/// Semantic and harmonious color tokens for the MacBite Widget,
/// aligned with MacBite's Core Design System.
enum WidgetColor {
    // MARK: - Surfaces & Backgrounds
    static let background = Color(uiColor: .secondarySystemGroupedBackground)
    static let borderSubtle = Color(uiColor: .separator).opacity(0.35)
    static let actionBackground = Color(uiColor: .tertiarySystemFill)

    // MARK: - Energy / Calories (MacBite Signature Brand Palette)
    static let calorie = Color(hex: 0xFA6934)
    static let calorieOverlimit = Color(hex: 0xF83623)

    // MARK: - Macronutrients (Harmonious Fitness Tracking Trio)
    static let protein = Color(hex: 0x3898EC)
    static let carbs = Color(hex: 0xF7D843)
    static let fat = Color(hex: 0xBF5AF2)

    // MARK: - Actions
    static let cameraActionTint = Color(hex: 0xFA6934)
    static let manualActionTint = Color.primary
}

// MARK: - Hex Initializer Helper

private extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 08) & 0xFF) / 255.0,
            blue: Double((hex >> 00) & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
