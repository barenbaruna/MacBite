//
//  AppTypography.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

enum AppTypography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.regular)
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body.weight(.regular)
    static let subheadline = Font.subheadline.weight(.regular)
    static let footnote = Font.footnote.weight(.regular)
    static let caption = Font.caption.weight(.regular)
    static let caption2 = Font.caption2.weight(.regular)
    static let button = Font.body.weight(.semibold)
    static let calorieRingValue = Font.largeTitle.scaled(by: 1.4).bold()
    static let nutritionValue = Font.title.bold()
    static let nutritionTarget = Font.title3.bold()
}
