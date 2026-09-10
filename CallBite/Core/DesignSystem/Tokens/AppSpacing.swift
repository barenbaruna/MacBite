//
//  AppSpacing.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import CoreGraphics

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40

    // MARK: - Semantic Scale Aliases

    static let extraSmall: CGFloat = xxs
    static let small: CGFloat = xs
    static let regular: CGFloat = sm
    static let medium: CGFloat = md
    static let large: CGFloat = lg
    static let extraLarge: CGFloat = xl
    static let extraExtraLarge: CGFloat = xxl

    // MARK: - Camera & Manual Logging Semantic Roles

    static let loggingOptionsBottomClearance: CGFloat = 104
    static let cameraTopControl: CGFloat = 52
    static let cameraGuideInset: CGFloat = 29
    static let cameraGuideTextTop: CGFloat = 148
    static let manualScreenMargin: CGFloat = 24
    static let manualCardInset: CGFloat = 12
    static let manualSectionGap: CGFloat = 24
    static let manualBottomButtonInset: CGFloat = 16
}
