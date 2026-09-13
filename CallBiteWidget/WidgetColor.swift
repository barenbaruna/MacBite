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

    // MARK: - Macronutrients (MacBite Design System Palette)
    /// Protein: LossWeight Accent (#02FBF4)
    static let protein = Color(hex: 0x02FBF4)
    /// Karbo: MainWeight Accent (#65FE4E)
    static let carbs = Color(hex: 0x65FE4E)
    /// Lemak: GainWeight Accent (#FF6B35)
    static let fat = Color(hex: 0xFF6B35)

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
