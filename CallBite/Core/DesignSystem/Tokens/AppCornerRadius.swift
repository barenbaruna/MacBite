//
//  AppCornerRadius.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import CoreGraphics

enum AppCornerRadius {
    // MARK: - Scale Primitives
    static let extraSmall: CGFloat = 6
    static let small: CGFloat = 10
    static let medium: CGFloat = 14
    static let large: CGFloat = 20
    static let extraLarge: CGFloat = 28
    static let ultraLarge: CGFloat = 42
    static let full: CGFloat = 999

    // MARK: - Semantic Role Aliases
    static let badge: CGFloat = extraSmall
    static let button: CGFloat = medium
    static let card: CGFloat = large
    static let sheet: CGFloat = extraLarge
    static let modalCard: CGFloat = ultraLarge
    static let pill: CGFloat = full
    static let cameraGuide: CGFloat = 36
}
