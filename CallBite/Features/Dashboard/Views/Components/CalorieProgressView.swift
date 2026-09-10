//
//  CalorieProgressView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Calorie progress ring displaying dynamic angular gradient fills and remaining calories.
public struct CalorieProgressView: View {
    public let consumedCalories: Int
    public let targetCalories: Int
    public let ringProgress: CGFloat
    public let ringScale: CGFloat
    public let rippleScale: CGFloat
    public let rippleOpacity: Double
    public let isDropletActive: Bool
    public let dropletScale: CGFloat
    public let dropletOpacity: Double

    public init(
        consumedCalories: Int = 1484,
        targetCalories: Int = 2654,
        ringProgress: CGFloat = 0.56,
        ringScale: CGFloat = 1.0,
        rippleScale: CGFloat = 0.5,
        rippleOpacity: Double = 0.0,
        isDropletActive: Bool = false,
        dropletScale: CGFloat = 1.0,
        dropletOpacity: Double = 1.0
    ) {
        self.consumedCalories = consumedCalories
        self.targetCalories = targetCalories
        self.ringProgress = ringProgress
        self.ringScale = ringScale
        self.rippleScale = rippleScale
        self.rippleOpacity = rippleOpacity
        self.isDropletActive = isDropletActive
        self.dropletScale = dropletScale
        self.dropletOpacity = dropletOpacity
    }

    private var remainingCalories: Int {
        max(0, targetCalories - consumedCalories)
    }

    private var isOverTarget: Bool {
        consumedCalories > targetCalories
    }

    private var overCalories: Int {
        max(0, consumedCalories - targetCalories)
    }

    private var angularGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: AppColor.ringYellow, location: 0.0),
                .init(color: AppColor.ringYellow, location: 0.06),
                .init(color: AppColor.ringOrange, location: 0.50),
                .init(color: AppColor.ringCoral, location: 0.94),
                .init(color: AppColor.ringCoral, location: 1.0)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }

    private var overflowGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: AppColor.fitnessOverflowStart, location: 0.0),
                .init(color: AppColor.fitnessOverflowMid, location: 0.45),
                .init(color: AppColor.fitnessOverflowEnd, location: 0.95),
                .init(color: AppColor.fitnessOverflowEnd, location: 1.0)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }

    public var body: some View {
        ZStack {
            rippleAuraEffect
            trackBackgroundCircle
            activeProgressRing

            if ringProgress > 1.0 {
                overlapSeamShadow
                overflowProgressRing
            }

            if isDropletActive {
                leadingTipGlowOrb
            }

            centerIndicatorContent
            apexArrowBadge
        }
        .frame(width: 238, height: 238)
        .scaleEffect(ringScale)
        .background(geometryReporter)
    }

    /// Glowing energy droplet located exactly at the leading tip of the active stroke
    private var leadingTipGlowOrb: some View {
        let progress = ringProgress > 1.0 ? (ringProgress - 1.0) : ringProgress
        let angleInDegrees = -90.0 + Double(progress) * 360.0
        let angleInRadians = angleInDegrees * .pi / 180.0
        let radius: CGFloat = 105.0
        let centerX: CGFloat = 119.0
        let centerY: CGFloat = 119.0
        let posX = centerX + radius * CGFloat(cos(angleInRadians))
        let posY = centerY + radius * CGFloat(sin(angleInRadians))

        return ZStack {
            Circle()
                .fill(isOverTarget ? AppColor.fitnessOverflowStart.opacity(0.40) : AppColor.ringYellow.opacity(0.40))
                .frame(width: 36, height: 36)
                .blur(radius: 5)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            isOverTarget ? AppColor.fitnessOverflowMid : AppColor.ringYellow,
                            isOverTarget ? AppColor.fitnessOverflowStart : AppColor.ringOrange
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 14
                    )
                )
                .frame(width: 28, height: 28)
                .shadow(
                    color: (isOverTarget ? AppColor.fitnessOverflowStart : AppColor.ringOrange).opacity(0.75),
                    radius: 4,
                    x: 0,
                    y: 0
                )

            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
        }
        .scaleEffect(dropletScale)
        .opacity(dropletOpacity)
        .position(x: posX, y: posY)
    }

    private var rippleAuraEffect: some View {
        Circle()
            .stroke(isOverTarget ? AppColor.fitnessOverflowStart : AppColor.ringYellow, lineWidth: 3)
            .frame(width: 140, height: 140)
            .scaleEffect(rippleScale)
            .opacity(rippleOpacity)
    }

    private var trackBackgroundCircle: some View {
        Circle()
            .stroke(AppColor.ringTrack, lineWidth: 28)
            .frame(width: 210, height: 210)
    }

    private var activeProgressRing: some View {
        Circle()
            .trim(from: 0, to: min(1.0, max(0.01, ringProgress)))
            .stroke(angularGradient, style: StrokeStyle(lineWidth: 28, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 210, height: 210)
    }

    /// Apple Fitness-style overlap shadow at 12 o'clock for multi-lap completion
    private var overlapSeamShadow: some View {
        Circle()
            .trim(from: 0.99, to: 1.0)
            .stroke(Color.black.opacity(0.65), style: StrokeStyle(lineWidth: 30, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 210, height: 210)
            .blur(radius: 4)
            .offset(y: 2)
    }

    /// Second lap ring rendered when calorie intake exceeds 100% of target
    private var overflowProgressRing: some View {
        let overflow = min(1.0, max(0.01, ringProgress - 1.0))
        return Circle()
            .trim(from: 0, to: overflow)
            .stroke(overflowGradient, style: StrokeStyle(lineWidth: 28, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 210, height: 210)
            .shadow(color: AppColor.fitnessOverflowStart.opacity(0.45), radius: 8, x: 0, y: 0)
    }

    private var centerIndicatorContent: some View {
        VStack(spacing: 2) {
            Text(verbatim: isOverTarget ? "+\(overCalories)" : "\(remainingCalories)")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(isOverTarget ? AppColor.fitnessOverflowStart : Color(uiColor: .label))
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(isOverTarget ? "calories over target" : "calories remaining")
                .font(AppTypography.subheadline)
                .foregroundStyle(Color(uiColor: .label))
        }
    }

    private var apexArrowBadge: some View {
        ZStack {
            Circle()
                .fill(AppColor.dark950.opacity(0.85))
                .frame(width: 22, height: 22)
            Image(systemName: "arrow.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(isOverTarget ? AppColor.fitnessOverflowStart : AppColor.gray200)
                .accessibilityHidden(true)
        }
        .offset(y: -105)
    }

    private var geometryReporter: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .named("saveFlowCoordinateSpace"))
            Color.clear.preference(
                key: RingGeometryPreferenceKey.self,
                value: RingGeometry(
                    center: CGPoint(x: frame.midX, y: frame.midY),
                    radius: 105.0
                )
            )
        }
    }
}

#Preview {
    ZStack {
        AppColor.dark950.ignoresSafeArea()
        CalorieProgressView()
    }
    .preferredColorScheme(.dark)
}
