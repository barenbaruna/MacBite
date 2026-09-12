//
//  AppGradient.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 10/09/26.
//

import SwiftUI

enum AppGradient {
    static let calorieRing = AngularGradient(
        stops: [
            .init(color: AppColor.ringYellow, location: 0.0),
            .init(color: AppColor.ringYellow, location: 0.18),
            .init(color: AppColor.ringOrange, location: 0.42),
            .init(color: AppColor.ringCoral, location: 0.70),
            .init(color: AppColor.ringRed, location: 0.90),
            .init(color: AppColor.ringRed, location: 1.0)
        ],
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )

    /// Closed-loop variant that blends back to its starting color at the ring seam.
    static let completedCalorieRing = AngularGradient(
        stops: [
            .init(color: AppColor.ringYellow, location: 0.0),
            .init(color: AppColor.ringYellow, location: 0.18),
            .init(color: AppColor.ringOrange, location: 0.42),
            .init(color: AppColor.ringCoral, location: 0.70),
            .init(color: AppColor.ringRed, location: 0.90),
            .init(color: AppColor.ringYellow, location: 1.0)
        ],
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )

    /// Completed first lap shown beneath the over-limit lap.
    static let calorieOverlimitBase = AngularGradient(
        stops: [
            .init(color: AppColor.overlimitBaseYellow, location: 0.0),
            .init(color: AppColor.overlimitBaseYellow, location: 0.25),
            .init(color: AppColor.overlimitBaseOrange, location: 0.50),
            .init(color: AppColor.overlimitBaseRed, location: 0.75),
            .init(color: AppColor.overlimitBaseRed, location: 1.0)
        ],
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )

    /// Closed-loop overflow gradient that avoids a hard radial join at 12 o'clock.
    static let calorieOverflow = AngularGradient(
        stops: [
            .init(color: AppColor.overlimitBaseRed, location: 0.0),
            .init(color: AppColor.overlimitCrimson, location: 0.056),
            .init(color: AppColor.overlimitMaroon, location: 0.097),
            .init(color: AppColor.overlimitCharcoalRed, location: 0.139),
            .init(color: AppColor.overlimitNearBlack, location: 0.18),
            .init(color: AppColor.overlimitNearBlack, location: 0.90),
            .init(color: AppColor.overlimitBaseRed, location: 1.0)
        ],
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )

    static let foodCardOverlay = LinearGradient(
        colors: [AppColor.foodCardOverlayLeading, AppColor.foodCardOverlayTrailing],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let foodCardFallback = LinearGradient(
        colors: [AppColor.dark950, AppColor.activityCardSelected],
        startPoint: .leading,
        endPoint: .trailing
    )
}
