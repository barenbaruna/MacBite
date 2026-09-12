//
//  ScientificWeightSlider.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Continuous 3-zone proportional ruler slider with equal 1/3 division, 1-tick-1-kg representation, full-width edge docking, and 3-color spectrum track.
struct ScientificWeightSlider: View {
    @Binding var value: Double
    var currentWeight: Double = 60.0
    let range: ClosedRange<Double>
    let healthyRange: ClosedRange<Double>
    var step: Double = 0.5

    @State private var isDragging: Bool = false
    @State private var lastReportedStep: Int = 0
    @State private var lastReportedZone: WeightRangeZone?

    private let sliderHeight: CGFloat = 68
    private let thumbWidth: CGFloat = 44
    private let thumbHeight: CGFloat = 28
    private let segmentGap: CGFloat = 8

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            if availableWidth > 60 {
                let layout = calculateLayout(availableWidth: availableWidth)
                let thumbX = calculateX(for: value, layout: layout)

                ZStack(alignment: .leading) {
                    // 1. Equal 1/3 borderless ruler tracks with container card and uniform ticks
                    rulerSegments(layout: layout, thumbX: thumbX)

                    // 2. Horizontal continuous 3-color spectrum track line (Cyan -> Green -> Coral)
                    horizontalCenterTrack(layout: layout, thumbX: thumbX)

                    // 3. Glowing white capsule thumb
                    thumbCapsule
                        .position(x: thumbX, y: sliderHeight / 2)
                }
                .frame(width: availableWidth, height: sliderHeight)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            updateValue(dragX: gesture.location.x, layout: layout)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
        }
        .frame(height: sliderHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weight Goal Slider")
        .accessibilityValue(String(format: "%.1f kg, %@", value, activeZone.title))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                applyValue(min(range.upperBound, value + 0.5))
            case .decrement:
                applyValue(max(range.lowerBound, value - 0.5))
            @unknown default:
                break
            }
        }
    }

    // MARK: - Subviews

    private func rulerSegments(layout: SliderLayout, thumbX: CGFloat) -> some View {
        let leftActiveRange: ClosedRange<CGFloat>? = {
            guard value < healthyRange.lowerBound else { return nil }
            let span = Double(layout.zone1EndKg - layout.zone1StartKg)
            let progress = span > 0 ? (Double(layout.zone1EndKg) - value) / span : 1.0
            let clampedProgress = min(max(CGFloat(progress), 0), 1)

            // When progress reaches 1.0 (mentok kiri), start reaches 0.0 exactly
            let start = layout.segmentWidth * (1.0 - clampedProgress)
            let end = layout.segmentWidth
            return min(start, end)...max(start, end)
        }()

        let rightActiveRange: ClosedRange<CGFloat>? = {
            guard value > healthyRange.upperBound else { return nil }
            let span = Double(layout.zone3EndKg - layout.zone3StartKg)
            let progress = span > 0 ? (value - Double(layout.zone3StartKg)) / span : 1.0
            let clampedProgress = min(max(CGFloat(progress), 0), 1)

            // When progress reaches 1.0 (mentok kanan), end reaches segmentWidth exactly
            let start: CGFloat = 0.0
            let end = layout.segmentWidth * clampedProgress
            return min(start, end)...max(start, end)
        }()

        return HStack(spacing: segmentGap) {
            // Zone 1: Below Recommended (Left: 10 uniform spacious ticks)
            RulerTicksSegment(
                width: layout.segmentWidth,
                height: sliderHeight,
                tickCount: 10,
                activeRange: leftActiveRange,
                accentColor: AppColor.goalCyan,
                boundaryEdge: .trailing
            )

            // Zone 2: Middle Recommended Range (Open gap)
            Color.clear
                .frame(width: layout.segmentWidth, height: sliderHeight)

            // Zone 3: Above Recommended (Right: 10 uniform spacious ticks)
            RulerTicksSegment(
                width: layout.segmentWidth,
                height: sliderHeight,
                tickCount: 10,
                activeRange: rightActiveRange,
                accentColor: AppColor.goalCoral,
                boundaryEdge: .leading
            )
        }
    }

    private func horizontalCenterTrack(layout: SliderLayout, thumbX: CGFloat) -> some View {
        let trackHeight: CGFloat = 5.5
        let outerInset: CGFloat = 6.0
        let trackWidth = max(0, layout.availableWidth - (outerInset * 2))

        let trackGradient = LinearGradient(
            stops: [
                .init(color: AppColor.goalCyan, location: 0.0),
                .init(color: AppColor.goalCyan, location: 0.28),
                .init(color: AppColor.goalGreen, location: 0.50),
                .init(color: AppColor.goalCoral, location: 0.72),
                .init(color: AppColor.goalCoral, location: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        let currentX = calculateX(for: currentWeight, layout: layout)

        return ZStack(alignment: .leading) {
            // 1. Subtle glow behind track line
            Capsule()
                .fill(trackGradient)
                .frame(width: trackWidth, height: trackHeight)
                .blur(radius: 3.0)
                .opacity(0.40)
                .offset(x: outerInset)

            // 2. Continuous 3-color spectrum track line (5.5pt thickened, flush with vertical ticks)
            Capsule()
                .fill(trackGradient)
                .frame(width: trackWidth, height: trackHeight)
                .offset(x: outerInset)

            // 3. Anchor dot at current weight position
            if range.contains(currentWeight) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .shadow(color: Color.black.opacity(0.5), radius: 2)
                    .position(x: currentX, y: sliderHeight / 2)
            }
        }
        .frame(width: layout.availableWidth, height: sliderHeight, alignment: .leading)
    }

    private var isMaintaining: Bool {
        abs(value - currentWeight) <= 0.5
    }

    private var activeGoalCategory: GoalCategory {
        if isMaintaining {
            return .maintaining
        } else if value < currentWeight {
            return .cutting
        } else {
            return .bulking
        }
    }

    private var activeIndicatorColor: Color {
        switch activeGoalCategory {
        case .cutting: return AppColor.goalCyan
        case .maintaining: return AppColor.goalGreen
        case .bulking: return AppColor.goalCoral
        }
    }

    private var thumbCapsule: some View {
        ZStack {
            // 1. Soft halo glow matching active category (selaras dengan tombol Done)
            Capsule(style: .continuous)
                .fill(activeIndicatorColor.opacity(0.45))
                .frame(width: thumbWidth + 8, height: thumbHeight + 8)
                .blur(radius: 4)

            // 2. White capsule with colored accent border
            Capsule(style: .continuous)
                .fill(Color.white)
                .frame(width: thumbWidth, height: thumbHeight)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(activeIndicatorColor, lineWidth: 3.0)
                )
                .shadow(
                    color: activeIndicatorColor.opacity(isMaintaining ? 0.60 : 0.40),
                    radius: isMaintaining ? 5 : 3,
                    x: 0,
                    y: 0
                )
                .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.75), value: isDragging)
        .animation(.smooth(duration: 0.2), value: activeIndicatorColor)
    }

    // MARK: - Layout & Value Computation

    private var activeZone: WeightRangeZone {
        if value < healthyRange.lowerBound {
            return .belowRecommended
        } else if value > healthyRange.upperBound {
            return .aboveRecommended
        } else {
            return .recommended
        }
    }
}

// MARK: - Layout & Interaction Math

extension ScientificWeightSlider {
    private func calculateLayout(availableWidth: CGFloat) -> SliderLayout {
        let safeAvailableWidth = max(availableWidth, 120)
        let usableWidth = max(0, safeAvailableWidth - (segmentGap * 2))
        let equalWidth = max(30, usableWidth / 3.0)

        let zone1StartKg = Int(range.lowerBound.rounded())
        let zone1EndKg = max(zone1StartKg + 1, Int(healthyRange.lowerBound.rounded()))

        let zone3StartKg = max(zone1EndKg + 1, Int(healthyRange.upperBound.rounded()))
        let zone3EndKg = max(zone3StartKg + 1, Int(range.upperBound.rounded()))

        let minThumbMargin = (thumbWidth / 2) + 4.0 // 26.0 pt keeps thumb and halo strictly within card bounds
        let zone1LocalStartX = minThumbMargin
        let zone1LocalEndX = max(zone1LocalStartX + 10, equalWidth - 4.0)

        let zone2Start = equalWidth + segmentGap
        let zone2End = (2.0 * equalWidth) + segmentGap

        let zone3Start = zone2End + segmentGap
        let zone3LocalStartX: CGFloat = 4.0
        let zone3LocalEndX = max(zone3LocalStartX + 10, equalWidth - minThumbMargin)

        return SliderLayout(
            availableWidth: availableWidth, segmentWidth: equalWidth,
            zone1StartKg: zone1StartKg, zone1EndKg: zone1EndKg,
            zone1LocalStartX: zone1LocalStartX, zone1LocalEndX: zone1LocalEndX,
            zone2Start: zone2Start, zone2End: zone2End, zone3Start: zone3Start,
            zone3StartKg: zone3StartKg, zone3EndKg: zone3EndKg,
            zone3LocalStartX: zone3LocalStartX, zone3LocalEndX: zone3LocalEndX
        )
    }

    private func calculateX(for weight: Double, layout: SliderLayout) -> CGFloat {
        if weight <= Double(layout.zone1EndKg) {
            let span = Double(layout.zone1EndKg - layout.zone1StartKg)
            let progress = span > 0 ? (weight - Double(layout.zone1StartKg)) / span : 0
            let clampedProgress = min(max(progress, 0), 1)
            let localSpan = layout.zone1LocalEndX - layout.zone1LocalStartX
            return layout.zone1LocalStartX + CGFloat(clampedProgress) * localSpan
        } else if weight >= Double(layout.zone3StartKg) {
            let span = Double(layout.zone3EndKg - layout.zone3StartKg)
            let progress = span > 0 ? (weight - Double(layout.zone3StartKg)) / span : 0
            let clampedProgress = min(max(progress, 0), 1)
            let localSpan = layout.zone3LocalEndX - layout.zone3LocalStartX
            let localX = layout.zone3LocalStartX + CGFloat(clampedProgress) * localSpan
            return layout.zone3Start + localX
        } else {
            // Zone 2 (Middle / Recommended WHO Range)
            let isCurrentInZone2 = healthyRange.contains(currentWeight)
            let span = Double(layout.zone3StartKg - layout.zone1EndKg)

            if isCurrentInZone2 {
                let midX = (layout.zone2Start + layout.zone2End) / 2.0
                let safeCurrent = currentWeight

                if weight <= safeCurrent {
                    let leftSpan = safeCurrent - Double(layout.zone1EndKg)
                    let progress = leftSpan > 0 ? (weight - Double(layout.zone1EndKg)) / leftSpan : 0.5
                    return layout.zone2Start + CGFloat(progress) * (midX - layout.zone2Start)
                } else {
                    let rightSpan = Double(layout.zone3StartKg) - safeCurrent
                    let progress = rightSpan > 0 ? (weight - safeCurrent) / rightSpan : 0.5
                    return midX + CGFloat(progress) * (layout.zone2End - midX)
                }
            } else {
                let progress = span > 0 ? (weight - Double(layout.zone1EndKg)) / span : 0.5
                let clampedProgress = min(max(progress, 0), 1)
                return layout.zone2Start + CGFloat(clampedProgress) * (layout.zone2End - layout.zone2Start)
            }
        }
    }

    private func updateValue(dragX: CGFloat, layout: SliderLayout) {
        let isCurrentInZone2 = healthyRange.contains(currentWeight)
        var calculatedValue: Double

        if dragX <= layout.zone1LocalStartX {
            calculatedValue = Double(layout.zone1StartKg)
        } else if dragX <= layout.zone1LocalEndX {
            let span = layout.zone1LocalEndX - layout.zone1LocalStartX
            let progress = Double((dragX - layout.zone1LocalStartX) / max(1, span))
            calculatedValue = Double(layout.zone1StartKg) + progress * Double(layout.zone1EndKg - layout.zone1StartKg)
        } else if dragX < layout.zone2Start {
            calculatedValue = Double(layout.zone1EndKg)
        } else if dragX <= layout.zone2End {
            let zone2Width = max(1, layout.zone2End - layout.zone2Start)
            let midFraction = Double((dragX - layout.zone2Start) / zone2Width)

            if isCurrentInZone2 {
                if abs(midFraction - 0.5) <= 0.05 {
                    calculatedValue = currentWeight
                } else if midFraction < 0.5 {
                    let progress = midFraction / 0.5
                    calculatedValue = Double(layout.zone1EndKg) + progress * (currentWeight - Double(layout.zone1EndKg))
                } else {
                    let progress = (midFraction - 0.5) / 0.5
                    calculatedValue = currentWeight + progress * (Double(layout.zone3StartKg) - currentWeight)
                }
            } else {
                let rangeDelta = layout.zone3StartKg - layout.zone1EndKg
                calculatedValue = Double(layout.zone1EndKg) + midFraction * Double(rangeDelta)
            }
        } else if dragX < layout.zone3Start + layout.zone3LocalStartX {
            calculatedValue = Double(layout.zone3StartKg)
        } else if dragX >= layout.zone3Start + layout.zone3LocalEndX {
            calculatedValue = Double(layout.zone3EndKg)
        } else {
            let localX = dragX - (layout.zone3Start + layout.zone3LocalStartX)
            let span = layout.zone3LocalEndX - layout.zone3LocalStartX
            let progress = Double(localX / max(1, span))
            calculatedValue = Double(layout.zone3StartKg) + progress * Double(layout.zone3EndKg - layout.zone3StartKg)
        }

        if abs(calculatedValue - currentWeight) <= 0.35 {
            calculatedValue = currentWeight
        }

        let stepped = (calculatedValue / step).rounded() * step
        let clamped = min(max(stepped, range.lowerBound), range.upperBound)
        applyValue(clamped)
    }

    private func applyValue(_ newValue: Double) {
        if newValue != value {
            value = newValue

            let stepInt = Int((newValue / step).rounded())
            if stepInt != lastReportedStep {
                lastReportedStep = stepInt
                if abs(newValue - currentWeight) <= 0.1 {
                    AppHaptics.selectionChanged()
                } else if healthyRange.contains(newValue) {
                    AppHaptics.sliderRecommendedTick()
                } else {
                    AppHaptics.sliderWarningTick()
                }
            }

            let newZone = activeZone
            if let last = lastReportedZone, newZone != last {
                AppHaptics.boundaryCrossed()
            }
            lastReportedZone = newZone
        }
    }
}

// MARK: - Internal Layout Helper

private struct SliderLayout {
    let availableWidth, segmentWidth: CGFloat
    let zone1StartKg, zone1EndKg: Int
    let zone1LocalStartX, zone1LocalEndX: CGFloat
    let zone2Start, zone2End, zone3Start: CGFloat
    let zone3StartKg, zone3EndKg: Int
    let zone3LocalStartX, zone3LocalEndX: CGFloat
}
