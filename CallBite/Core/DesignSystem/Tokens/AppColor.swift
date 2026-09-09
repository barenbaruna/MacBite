//
//  AppColor.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

enum AppColor {

    // MARK: - Brand Primary (Orange Palette)

    static let primary100 = Color(hex: 0xFFDCCE)
    static let primary200 = Color(hex: 0xFFBBA3)
    static let primary300 = Color(hex: 0xFF9878)
    static let primary400 = Color(hex: 0xED7445)
    static let primary500 = Color(hex: 0xD85F34)

    // MARK: - Brand Secondary (Dark Palette)

    static let secondary900 = Color(hex: 0x19191B)
    static let secondary950 = Color(hex: 0x0C0C0E)

    // MARK: - Neutral / Grayscale

    static let neutral100 = Color(hex: 0xF7F7F7)
    static let neutral200 = Color(hex: 0xE8E8E8)
    static let neutral300 = Color(hex: 0xD1D1D2)
    static let neutral400 = Color(hex: 0xB2B2B4)
    static let neutral500 = Color(hex: 0x858588)
    static let neutral600 = Color(hex: 0x5C5C60)
    static let neutral700 = Color(hex: 0x3E3E42)
    static let neutral800 = Color(hex: 0x29292C)

    // MARK: - Semantic (Adaptive Light/Dark)

    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)

    // MARK: - Domain Nutrition

    static let calorie = Color.orange
    static let protein = Color.blue
    static let carbs = Color.yellow
    static let fat = Color.purple

    // MARK: - System & Integration Semantics

    static let healthBlue = Color(hex: 0x007AFF)
    static let buttonDisabled = Color(hex: 0x5A5A5E)
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
