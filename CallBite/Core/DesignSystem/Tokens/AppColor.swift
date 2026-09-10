//
//  AppColor.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

enum AppColor {
    // Orange Series
    static let orange100 = Color(hex: 0xFFDCCE)
    static let orange200 = Color(hex: 0xFFBBA3)
    static let orange300 = Color(hex: 0xFF9878)
    static let orange400 = Color(hex: 0xED7445)
    static let orange500 = Color(hex: 0xD85F34)

    // Dark Series
    static let dark900 = Color(hex: 0x19191B)
    static let dark950 = Color(hex: 0x0C0C0E)

    // Neutral / Grayscale Series
    static let white = Color(hex: 0xFFFFFF)
    static let gray200 = Color(hex: 0xD1D1D2)
    static let gray300 = Color(hex: 0xB2B2B4)

    // Semantic Accents
    static let healthBlue = Color(hex: 0x007AFF)
    static let goalCyan = Color(hex: 0x00F0FF)
    static let goalGreen = Color(hex: 0x30D158)
    static let goalCoral = Color(hex: 0xFF6B4A)
    static let buttonDisabled = Color(hex: 0x5A5A5E)

    // Logging Flow
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let loggingOptionBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let loggingOptionForeground = Color(uiColor: .label)
    static let floatingAction = Color(uiColor: .label)

    // Camera Flow
    static let cameraControlBackground = Color(hex: 0xEAEAEA)
    static let cameraGuideForeground = Color(hex: 0x332B20)
    static let cameraGuideButtonBackground = Color(hex: 0x5E5E5E)
    static let cameraTipBackground = Color(hex: 0x8A8A8A)
    static let cameraTipHeaderBackground = Color(hex: 0x727272)
    static let cameraActionBar = Color(hex: 0x000000)

    // Manual Logging Flow
    static let manualFieldBackground = Color(hex: 0x2C2C2E)
    static let manualInputForeground = Color(hex: 0xCCCCCC)
    static let manualSeparator = Color(hex: 0x3A3A3C)
}

// MARK: - Hex Initializer Helper

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: opacity
        )
    }
}
