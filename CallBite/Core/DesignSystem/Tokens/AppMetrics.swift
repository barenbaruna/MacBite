//
//  AppMetrics.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 10/09/26.
//

import CoreGraphics

public enum AppMetrics {
    // MARK: - Calorie Ring & Energy Orb
    public static let calorieRingStrokeWidth: CGFloat = 32
    public static let calorieRingRippleWidth: CGFloat = 3
    public static let energyDropletSize: CGFloat = 28

    // MARK: - Floating Modal Card
    public static let modalCardMaxWidth: CGFloat = 360
    public static let modalCardMaxHeight: CGFloat = 620
    public static let modalCardHeightRatio: CGFloat = 0.74
    public static let modalCardShadowRadius: CGFloat = 28

    // MARK: - Standard Control Heights
    public static let primaryButtonHeight: CGFloat = 50
    public static let iconButtonSize: CGFloat = 32

    // MARK: - Camera Guidance
    public static let cameraSafeAreaTopRatio: CGFloat = 0.237
    public static let cameraSafeAreaHeightRatio: CGFloat = 0.36

    // MARK: - Calendar
    public static let calorieRingStartAngle: Double = -90
    public static let calorieRingSeamOverlapDegrees: Double = 20
    public static let calendarDisabledOpacity: Double = 0.35
}
