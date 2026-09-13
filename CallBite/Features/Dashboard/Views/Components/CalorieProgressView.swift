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

    public var body: some View {
        ZStack {
            rippleAuraEffect
            trackBackgroundCircle
            activeProgressRing

            if ringProgress > 0.0 && ringProgress < 1.0 {
                partialProgressStartCap
            }

            if ringProgress > 1.0 {
                overflowProgressRing
                overflowTipCap
            }

            if isDropletActive {
                leadingTipGlowOrb
            }

            centerIndicatorContent
        }
        .frame(width: AppSize.calorieRingCanvas, height: AppSize.calorieRingCanvas)
        .scaleEffect(ringScale)
        .background(geometryReporter)
    }

    /// Glowing energy droplet located exactly at the leading tip of the active stroke
    private var leadingTipGlowOrb: some View {
        let progress = ringProgress > 1.0 ? (ringProgress - 1.0) : ringProgress
        let angleInDegrees = -90.0 + Double(progress) * 360.0
        let angleInRadians = angleInDegrees * .pi / 180.0
        let radius = AppSize.calorieRingRadius
        let centerX = AppSize.calorieRingCanvas / 2
        let centerY = AppSize.calorieRingCanvas / 2
        let posX = centerX + radius * CGFloat(cos(angleInRadians))
        let posY = centerY + radius * CGFloat(sin(angleInRadians))

        return ZStack {
            Circle()
                .fill(isOverTarget ? AppColor.overlimitCrimson.opacity(0.40) : AppColor.ringYellow.opacity(0.40))
                .frame(width: AppSize.calorieRingGlowDiameter, height: AppSize.calorieRingGlowDiameter)
                .blur(radius: 5)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            isOverTarget ? AppColor.overlimitMaroon : AppColor.ringYellow,
                            isOverTarget ? AppColor.overlimitCrimson : AppColor.ringOrange
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 14
                    )
                )
                .frame(width: AppMetrics.energyDropletSize, height: AppMetrics.energyDropletSize)
                .shadow(
                    color: (isOverTarget ? AppColor.overlimitCrimson : AppColor.ringOrange).opacity(0.75),
                    radius: 4,
                    x: 0,
                    y: 0
                )

            Circle()
                .fill(Color.white)
                .frame(width: AppSize.calorieRingHighlightDiameter, height: AppSize.calorieRingHighlightDiameter)
        }
        .scaleEffect(dropletScale)
        .opacity(dropletOpacity)
        .position(x: posX, y: posY)
    }

    private var rippleAuraEffect: some View {
        Circle()
            .stroke(
                isOverTarget ? AppColor.overlimitCrimson : AppColor.ringYellow,
                lineWidth: AppMetrics.calorieRingRippleWidth
            )
            .frame(width: AppSize.calorieRingRippleDiameter, height: AppSize.calorieRingRippleDiameter)
            .scaleEffect(rippleScale)
            .opacity(rippleOpacity)
    }

    private var trackBackgroundCircle: some View {
        Circle()
            .stroke(AppColor.ringTrack, lineWidth: AppMetrics.calorieRingStrokeWidth)
            .frame(width: AppSize.calorieRingDiameter, height: AppSize.calorieRingDiameter)
    }

    private var activeProgressRing: some View {
        let gradient: AngularGradient
        if ringProgress > 1.0 {
            gradient = AppGradient.calorieOverlimitBase
        } else if ringProgress >= 1.0 {
            gradient = AppGradient.completedCalorieRing
        } else {
            gradient = AppGradient.calorieRing
        }

        return Circle()
            .trim(from: 0, to: min(1.0, max(0, ringProgress)))
            .stroke(
                gradient,
                style: StrokeStyle(
                    lineWidth: AppMetrics.calorieRingStrokeWidth,
                    lineCap: ringProgress < 1.0 ? .round : .butt
                )
            )
            .rotationEffect(.degrees(AppMetrics.calorieRingStartAngle))
            .frame(width: AppSize.calorieRingDiameter, height: AppSize.calorieRingDiameter)
    }

    /// Solid start cap prevents the angular gradient's red endpoint from wrapping behind yellow.
    private var partialProgressStartCap: some View {
        Circle()
            .fill(AppColor.ringYellow)
            .frame(width: AppMetrics.calorieRingStrokeWidth, height: AppMetrics.calorieRingStrokeWidth)
            .position(
                x: AppSize.calorieRingCanvas / 2,
                y: AppSize.calorieRingCanvas / 2 - AppSize.calorieRingRadius
            )
    }

    /// Second lap ring rendered when calorie intake exceeds 100% of target
    private var overflowProgressRing: some View {
        let overflow = min(1.0, max(0.005, ringProgress - 1.0))
        let overlapDegrees = AppMetrics.calorieRingSeamOverlapDegrees
        let overlapFraction = overlapDegrees / 360.0
        return Circle()
            .trim(from: 0, to: min(1.0, overlapFraction + overflow))
            .stroke(
                AppGradient.calorieOverflow,
                style: StrokeStyle(lineWidth: AppMetrics.calorieRingStrokeWidth, lineCap: .butt)
            )
            .rotationEffect(.degrees(AppMetrics.calorieRingStartAngle - overlapDegrees))
            .frame(width: AppSize.calorieRingDiameter, height: AppSize.calorieRingDiameter)
    }

    /// Leading rounded tip of the overflow lap casting a drop shadow onto the base ring beneath it
    private var overflowTipCap: some View {
        let overflow = min(1.0, max(0.005, ringProgress - 1.0))
        let overlapFraction = AppMetrics.calorieRingSeamOverlapDegrees / 360.0
        let angleInDegrees = AppMetrics.calorieRingStartAngle + Double(overflow) * 360.0
        let angleInRadians = angleInDegrees * .pi / 180.0
        let radius = AppSize.calorieRingRadius
        let centerX = AppSize.calorieRingCanvas / 2
        let centerY = AppSize.calorieRingCanvas / 2
        let posX = centerX + radius * CGFloat(cos(angleInRadians))
        let posY = centerY + radius * CGFloat(sin(angleInRadians))

        // Clockwise motion tangent vector for directional drop shadow
        let tangentX = CGFloat(-sin(angleInRadians))
        let tangentY = CGFloat(cos(angleInRadians))

        return Circle()
            .fill(AppColor.overlimitColor(at: overlapFraction + overflow))
            .frame(width: AppMetrics.calorieRingStrokeWidth, height: AppMetrics.calorieRingStrokeWidth)
            .shadow(
                color: Color.black.opacity(0.55),
                radius: 3,
                x: tangentX * 2.5,
                y: tangentY * 2.5
            )
            .position(x: posX, y: posY)
    }

    @ViewBuilder
    private var centerIndicatorContent: some View {
        if isOverTarget {
            VStack(spacing: AppSpacing.extraSmall) {
                Text(verbatim: "+\(overCalories)")
                    .font(AppTypography.calorieRingValue)
                    .foregroundStyle(AppColor.overlimitText)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text("calories over target")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(Color(uiColor: .label))
            }
        } else {
            VStack(spacing: AppSpacing.small) {
                Text("Remaining")
                    .font(AppTypography.body)
                    .foregroundStyle(Color(uiColor: .label))

                Text(verbatim: "\(remainingCalories)")
                    .font(AppTypography.calorieRingValue)
                    .foregroundStyle(AppColor.ringValue)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text(verbatim: "of \(targetCalories) KCAL")
                    .font(AppTypography.body)
                    .foregroundStyle(Color(uiColor: .label))
                    .monospacedDigit()
            }
        }
    }

    private var geometryReporter: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .named("saveFlowCoordinateSpace"))
            Color.clear.preference(
                key: RingGeometryPreferenceKey.self,
                value: RingGeometry(
                    center: CGPoint(x: frame.midX, y: frame.midY),
                    radius: AppSize.calorieRingRadius
                )
            )
        }
    }
}

#Preview("Normal Progress") {
    ZStack {
        AppColor.dark950.ignoresSafeArea()
        CalorieProgressView(
            consumedCalories: 1484,
            targetCalories: 2654,
            ringProgress: 0.56
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Overlimit Progress") {
    ZStack {
        AppColor.dark950.ignoresSafeArea()
        CalorieProgressView(
            consumedCalories: 3008,
            targetCalories: 2654,
            ringProgress: 1.133
        )
    }
    .preferredColorScheme(.dark)
}
