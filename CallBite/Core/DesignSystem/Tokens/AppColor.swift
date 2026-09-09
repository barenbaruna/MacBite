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
