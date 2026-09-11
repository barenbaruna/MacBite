//
//  AppColor.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

enum AppColor {
    // Surfaces & Backgrounds (Semantic Apple HIG)
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let borderSubtle = Color(uiColor: .separator).opacity(0.35)

    // Orange Series
    static let orange100 = Color(hex: 0xFFDCCE)
    static let orange200 = Color(hex: 0xFFBBA3)
    static let orange300 = Color(hex: 0xFF9878)
    static let orange400 = Color(hex: 0xED7445)
    static let orange500 = Color(hex: 0xD85F34)

    // Dark Series
    static let dark800 = Color(hex: 0x26242E)
    static let dark900 = Color(hex: 0x19191B)
    static let dark950 = Color(hex: 0x0C0C0E)

    // Activity Cards (Lifestyle)
    static let activityCardNormal = Color(hex: 0x1C1C1E)
    static let activityCardSelected = Color(hex: 0x3D3E42)
    static let activityCardSelectedBorder = Color.white.opacity(0.3)

    // Neutral / Grayscale Series
    static let white = Color(hex: 0xFFFFFF)
    static let gray200 = Color(hex: 0xD1D1D2)
    static let gray300 = Color(hex: 0xB2B2B4)

    // Official Designer Palette (Weight Goals & Accents)
    static let lossWeight = Color(hex: 0x02FBF4)
    static let mainWeight = Color(hex: 0x65FE4E)
    static let gainWeight = Color(hex: 0xFF6B35)
    static let circleOne = Color(hex: 0xF7D843)
    static let circleTwo = Color(hex: 0xEF3826)

    // Semantic Accents
    static let healthBlue = Color(hex: 0x007AFF)
    static let goalCyan = lossWeight
    static let goalGreen = mainWeight
    static let goalCoral = gainWeight
    static let buttonDisabled = Color(hex: 0x5A5A5E)

    // Nutrition Domain (PRD & Design System)
    static let calorie = orange500
    static let protein = Color.blue
    static let carbs = Color.yellow
    static let fat = Color.purple

    // Ring Classic Angular Gradient Series (Figma #F7E43F -> Orange -> Red)
    static let ringYellow = Color(hex: 0xF7E43F)
    static let ringOrange = Color(hex: 0xFF7A00)
    static let ringCoral = Color(hex: 0xE53935)
    static let ringTrack = Color(hex: 0x222126)
    static let avatarBackground = Color(hex: 0xE65100)

    // Slider Gradient Series
    static let sliderLoss = lossWeight
    static let sliderMaintain = mainWeight
    static let sliderGain = gainWeight
    static let sliderEmerald = mainWeight
    static let sliderCyan = lossWeight
    static let sliderMagenta = gainWeight

    // Apple Fitness Over-Goal Multi-Lap Series (Electric Neon Rose -> Hot Magenta)
    static let fitnessOverflowStart = Color(hex: 0xFF2D55)
    static let fitnessOverflowMid = Color(hex: 0xFF375F)
    static let fitnessOverflowEnd = Color(hex: 0xFF007A)

    // Liquid Glass Atmospheric Surface Series (Save Food Confirmation & Modal Glass)
    static let glassSurfaceBase = Color(hex: 0x1A1815)
    static let glassSurfaceDark = Color(hex: 0x121110)
    static let glassAmbientAmber = Color(hex: 0xE5A352)
    static let glassAmbientAmberDeep = Color(hex: 0x7A4C1E)
    static let glassAmbientAmberSoft = Color(hex: 0xD48A3C)
    static let glassTextMuted = Color(hex: 0xA69F94)

    // Logging Flow
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
