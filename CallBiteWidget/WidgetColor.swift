//
//  WidgetColor.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

/// Semantic and harmonious color tokens for the MacBite Widget,
/// strictly following MacBite's Core Design System.
enum WidgetColor {
    // MARK: - Surfaces & Backgrounds
    static let background = Color(uiColor: .secondarySystemGroupedBackground)
    static let borderSubtle = Color(uiColor: .separator).opacity(0.35)
    static let actionBackground = Color(uiColor: .tertiarySystemFill)

    // MARK: - Energy / Calories (Official Designer Palette: GainWeight #FF6B35)
    static let calorie = Color(hex: 0xFF6B35)
    static let calorieOverlimit = Color(hex: 0xEF3826)

    // MARK: - Macronutrients (Design System PRD Section 6: Blue, Yellow, Purple)
    static let protein = Color.blue
    static let carbs = Color.yellow
    static let fat = Color.purple

    // MARK: - Actions
    static let cameraActionTint = Color(hex: 0xFF6B35)
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
