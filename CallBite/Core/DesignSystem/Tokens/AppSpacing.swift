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
    static let cameraGuideContentTopInset: CGFloat = 48
    static let cameraGuideIconTextSpacing: CGFloat = 28
    static let cameraGuideTextButtonGap: CGFloat = 16
    static let cameraSafeAreaHorizontalInset: CGFloat = 40
    static let cameraGuideToInstruction: CGFloat = 24
    static let cameraInstructionToStatus: CGFloat = 50
    static let cameraStatusToControls: CGFloat = 24
    static let cameraInstructionContentInset: CGFloat = 20
    static let cameraCloseTopInset: CGFloat = 38
    static let cameraCloseHorizontalInset: CGFloat = 31
    static let cameraBottomControlsHorizontalInset: CGFloat = 59
    static let cameraBottomControlsInset: CGFloat = 74
    static let manualScreenMargin: CGFloat = 24
    static let manualCardInset: CGFloat = 12
    static let manualSectionGap: CGFloat = 24
    static let manualBottomButtonInset: CGFloat = 16

    // MARK: - Calendar Semantic Roles

    static let calendarSheetInset: CGFloat = 24
    static let calendarMonthSpacing: CGFloat = 32
    static let calendarHeaderSpacing: CGFloat = 16
    static let calendarGridSpacing: CGFloat = 8

    // MARK: - Dashboard Food History
    static let dashboardFoodSectionTopSpacing: CGFloat = extraExtraLarge
    static let dashboardFoodSectionHeaderInset: CGFloat = regular
    static let dashboardFoodCardContentInset: CGFloat = 27
    static let dashboardFoodCardSpacing: CGFloat = regular
    static let dashboardMacroCardInset: CGFloat = 21
}
