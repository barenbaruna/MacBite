//
//  ScientificWeightSlider.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Continuous 3-zone proportional ruler slider for scientific weight goal selection.
struct ScientificWeightSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let healthyRange: ClosedRange<Double>
    var step: Double = 0.5

    @State private var isDragging: Bool = false
    @State private var lastReportedStep: Int = 0
    @State private var lastReportedZone: WeightRangeZone?

    private let sliderHeight: CGFloat = 54
    private let thumbWidth: CGFloat = 36
    private let thumbHeight: CGFloat = 22
    private let segmentGap: CGFloat = 6

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            let layout = calculateLayout(availableWidth: availableWidth)
            let thumbX = calculateThumbX(layout: layout)

            ZStack(alignment: .leading) {
                // 1. Proportional 3-zone ruler tracks
                rulerSegments(layout: layout)

                // 2. Horizontal continuous track line
                horizontalCenterTrack(availableWidth: availableWidth, thumbX: thumbX)

                // 3. Sleek white capsule thumb
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

    private func rulerSegments(layout: SliderLayout) -> some View {
        HStack(spacing: segmentGap) {
            // Below Recommended Zone
            RulerZoneSegment(
                width: layout.belowWidth,
                height: sliderHeight,
                isActive: activeZone == .belowRecommended,
                accentColor: AppColor.goalCyan
            )

            // Recommended Range Zone
            RulerZoneSegment(
                width: layout.recommendedWidth,
                height: sliderHeight,
                isActive: activeZone == .recommended,
                accentColor: AppColor.goalGreen
            )

            // Above Recommended Zone
            RulerZoneSegment(
                width: layout.aboveWidth,
                height: sliderHeight,
                isActive: activeZone == .aboveRecommended,
                accentColor: AppColor.goalCoral
            )
        }
    }

    private func horizontalCenterTrack(availableWidth: CGFloat, thumbX: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            // Inactive base track
            Capsule()
                .fill(Color.white.opacity(0.16))
                .frame(width: availableWidth, height: 2.5)

            // Active progress line
            Capsule()
                .fill(activeColor)
                .frame(width: max(0, thumbX), height: 2.5)
        }
        .frame(height: sliderHeight)
    }

    private var thumbCapsule: some View {
        Capsule(style: .continuous)
            .fill(Color.white)
            .frame(width: thumbWidth, height: thumbHeight)
            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
            .scaleEffect(isDragging ? 1.06 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: isDragging)
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

    private var activeColor: Color {
        switch activeZone {
        case .belowRecommended: return AppColor.goalCyan
        case .recommended: return AppColor.goalGreen
        case .aboveRecommended: return AppColor.goalCoral
        }
    }

    private func calculateLayout(availableWidth: CGFloat) -> SliderLayout {
        let totalSpan = max(1.0, range.upperBound - range.lowerBound)
        let belowSpan = max(0.0, healthyRange.lowerBound - range.lowerBound)
        let recommendedSpan = max(0.0, healthyRange.upperBound - healthyRange.lowerBound)
        let aboveSpan = max(0.0, range.upperBound - healthyRange.upperBound)

        let usableWidth = max(0, availableWidth - (segmentGap * 2))
        let belowW = max(10, (belowSpan / totalSpan) * usableWidth)
        let recW = max(10, (recommendedSpan / totalSpan) * usableWidth)
        let aboveW = max(10, usableWidth - belowW - recW)

        return SliderLayout(
            availableWidth: availableWidth,
            belowWidth: belowW,
            recommendedWidth: recW,
            aboveWidth: aboveW,
            belowSpan: belowSpan,
            recommendedSpan: recommendedSpan,
            aboveSpan: aboveSpan
        )
    }

    private func calculateThumbX(layout: SliderLayout) -> CGFloat {
        let halfThumb = thumbWidth / 2
        let minX = halfThumb
        let maxX = layout.availableWidth - halfThumb

        let rawX: CGFloat
        if value <= healthyRange.lowerBound {
            let fraction = layout.belowSpan > 0 ? (value - range.lowerBound) / layout.belowSpan : 0
            rawX = CGFloat(fraction) * layout.belowWidth
        } else if value <= healthyRange.upperBound {
            let fraction = layout.recommendedSpan > 0 ? (value - healthyRange.lowerBound) / layout.recommendedSpan : 0
            rawX = layout.belowWidth + segmentGap + (CGFloat(fraction) * layout.recommendedWidth)
        } else {
            let fraction = layout.aboveSpan > 0 ? (value - healthyRange.upperBound) / layout.aboveSpan : 0
            let startOffset = layout.belowWidth + segmentGap + layout.recommendedWidth + segmentGap
            rawX = startOffset + (CGFloat(fraction) * layout.aboveWidth)
        }

        return min(max(rawX, minX), maxX)
    }

    private func updateValue(dragX: CGFloat, layout: SliderLayout) {
        let clampedX = min(max(dragX, 0), layout.availableWidth)
        let seg1End = layout.belowWidth
        let seg2Start = seg1End + segmentGap
        let seg2End = seg2Start + layout.recommendedWidth
        let seg3Start = seg2End + segmentGap

        let calculatedValue: Double
        if clampedX <= seg1End {
            let fraction = Double(clampedX / max(1, seg1End))
            calculatedValue = range.lowerBound + fraction * layout.belowSpan
        } else if clampedX < seg2Start {
            calculatedValue = healthyRange.lowerBound
        } else if clampedX <= seg2End {
            let fraction = Double((clampedX - seg2Start) / max(1, layout.recommendedWidth))
            calculatedValue = healthyRange.lowerBound + fraction * layout.recommendedSpan
        } else if clampedX < seg3Start {
            calculatedValue = healthyRange.upperBound
        } else {
            let fraction = Double((clampedX - seg3Start) / max(1, layout.aboveWidth))
            calculatedValue = healthyRange.upperBound + min(1.0, fraction) * layout.aboveSpan
        }

        let stepped = (calculatedValue / step).rounded() * step
        let clamped = min(max(stepped, range.lowerBound), range.upperBound)
        applyValue(clamped)
    }

    private func applyValue(_ newValue: Double) {
        if newValue != value {
            value = newValue

            // Step tick haptic (crisp, smooth mechanical feedback per 0.5 kg)
            let stepInt = Int((newValue / step).rounded())
            if stepInt != lastReportedStep {
                lastReportedStep = stepInt
                AppHaptics.sliderTick()
            }

            // Boundary crossed haptic (firm physical impact entering/exiting zones)
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
    let availableWidth: CGFloat
    let belowWidth: CGFloat
    let recommendedWidth: CGFloat
    let aboveWidth: CGFloat
    let belowSpan: Double
    let recommendedSpan: Double
    let aboveSpan: Double
}

// MARK: - Ruler Zone Segment Subview

private struct RulerZoneSegment: View {
    let width: CGFloat
    let height: CGFloat
    let isActive: Bool
    let accentColor: Color

    private let tickSpacing: CGFloat = 5.0
    private let tickWidth: CGFloat = 1.5

    var body: some View {
        ZStack {
            // Background glow when active
            if isActive {
                RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.32), accentColor.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            }

            // Vertical ruler ticks
            Canvas { context, size in
                let tickColor = isActive ? accentColor.opacity(0.9) : Color.white.opacity(0.12)
                var currentX: CGFloat = tickSpacing

                while currentX < size.width {
                    let rect = CGRect(x: currentX, y: 6, width: tickWidth, height: size.height - 12)
                    context.fill(Path(rect), with: .color(tickColor))
                    currentX += tickSpacing
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous)
                .stroke(isActive ? accentColor.opacity(0.45) : Color.white.opacity(0.06), lineWidth: 1)
        )
        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isActive)
    }
}
