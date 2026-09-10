//
//  ScientificWeightSlider.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Custom continuous slider with boundary indicators for setting weight goals.
struct ScientificWeightSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let healthyRange: ClosedRange<Double>
    var step: Double = 0.5

    @State private var isDragging: Bool = false
    @State private var lastReportedInteger: Int = 0

    private let trackHeight: CGFloat = 12
    private let thumbDiameter: CGFloat = 28

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width - thumbDiameter
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let clampedProgress = min(max(progress, 0.0), 1.0)
            let thumbOffset = clampedProgress * availableWidth

            sliderTrackContent(availableWidth: availableWidth, thumbOffset: thumbOffset)
        }
        .frame(height: thumbDiameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weight Goal Slider")
        .accessibilityValue(String(format: "%.1f kg", value))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                value = min(range.upperBound, value + 1.0)
            case .decrement:
                value = max(range.lowerBound, value - 1.0)
            @unknown default:
                break
            }
        }
    }

    private func sliderTrackContent(availableWidth: CGFloat, thumbOffset: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            inactiveTrackBackground
            activeGradientTrack(thumbOffset: thumbOffset)
            thumbScrubber(availableWidth: availableWidth, thumbOffset: thumbOffset)
            boundaryWarningBadge(thumbOffset: thumbOffset)
        }
        .frame(height: thumbDiameter)
    }

    private var inactiveTrackBackground: some View {
        Capsule()
            .fill(Color(.systemGray5).opacity(0.3))
            .frame(height: trackHeight)
    }

    private func activeGradientTrack(thumbOffset: CGFloat) -> some View {
        let gradient = LinearGradient(
            colors: [AppColor.lossWeight, AppColor.mainWeight, AppColor.gainWeight],
            startPoint: .leading,
            endPoint: .trailing
        )

        return Capsule()
            .fill(gradient)
            .frame(width: thumbOffset + (thumbDiameter / 2), height: trackHeight)
            .mask(Capsule())
    }

    private func thumbScrubber(availableWidth: CGFloat, thumbOffset: CGFloat) -> some View {
        thumbKnob
            .offset(x: thumbOffset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        updateValue(dragX: gesture.location.x, availableWidth: availableWidth)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
    }

    @ViewBuilder
    private func boundaryWarningBadge(thumbOffset: CGFloat) -> some View {
        if value > healthyRange.upperBound && isDragging {
            Text("ABOVE RECOMMENDED RANGE")
                .font(AppTypography.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AppColor.gainWeight)
                .clipShape(Capsule())
                .offset(x: thumbOffset - 60, y: -24)
        } else if value < healthyRange.lowerBound && isDragging {
            Text("BELOW RECOMMENDED RANGE")
                .font(AppTypography.caption.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AppColor.lossWeight)
                .clipShape(Capsule())
                .offset(x: thumbOffset - 60, y: -24)
        }
    }

    private var currentAccentColor: Color {
        if value < healthyRange.lowerBound {
            return AppColor.lossWeight
        } else if value > healthyRange.upperBound {
            return AppColor.gainWeight
        } else {
            return AppColor.mainWeight
        }
    }

    private var thumbKnob: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: thumbDiameter, height: thumbDiameter)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            
            // Center indicator reflecting current active color
            Circle()
                .fill(currentAccentColor)
                .frame(width: 8, height: 8)
        }
        .scaleEffect(isDragging ? 1.08 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isDragging)
    }

    private func updateValue(dragX: CGFloat, availableWidth: CGFloat) {
        guard availableWidth > 0 else { return }
        let rawFraction = (dragX - (thumbDiameter / 2)) / availableWidth
        let clampedFraction = Double(min(max(rawFraction, 0.0), 1.0))
        let rawValue = range.lowerBound + clampedFraction * (range.upperBound - range.lowerBound)
        let steppedValue = (rawValue / step).rounded() * step
        let finalValue = min(max(steppedValue, range.lowerBound), range.upperBound)

        if finalValue != value {
            value = finalValue
            let currentInt = Int(finalValue)
            if currentInt != lastReportedInteger {
                lastReportedInteger = currentInt
            }
        }
    }
}

// MARK: - Hatched Pattern Shape
struct HatchedPattern: Shape {
    let lineSpacing: CGFloat = 8
    let lineWidth: CGFloat = 2
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Draw diagonal lines starting from x=0
        for x in stride(from: -height, to: width, by: lineSpacing) {
            path.move(to: CGPoint(x: x, y: height))
            path.addLine(to: CGPoint(x: x + height, y: 0))
        }
        
        // Using stroke instead of fill to respect line width
        return path.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .square))
    }
}
