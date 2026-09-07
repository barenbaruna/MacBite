//
//  ScientificWeightSlider.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

struct ScientificWeightSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.5

    @State private var isDragging: Bool = false
    @State private var lastReportedInteger: Int = 0

    private let trackHeight: CGFloat = 6
    private let thumbWidth: CGFloat = 34
    private let thumbHeight: CGFloat = 22

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(10, proxy.size.width - thumbWidth)
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let clampedProgress = min(max(progress, 0.0), 1.0)
            let thumbOffset = clampedProgress * availableWidth

            ZStack(alignment: .leading) {
                // 1. Background Inactive Track
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: trackHeight)

                // 2. Active Blue Progress Track
                Capsule()
                    .fill(Color.blue)
                    .frame(width: thumbOffset + (thumbWidth / 2), height: trackHeight)

                // 3. Tick Dots Along Track
                tickDotsOverlay(totalWidth: proxy.size.width)

                // 4. Custom Scrubbing Thumb Knob
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
            .frame(height: 36)
        }
        .frame(height: 36)
        .padding(.horizontal, AppSpacing.lg)
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

    private var thumbKnob: some View {
        Capsule()
            .fill(Color.white)
            .frame(width: thumbWidth, height: thumbHeight)
            .shadow(color: .black.opacity(0.18), radius: isDragging ? 6 : 4, y: 2)
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
            )
            .scaleEffect(isDragging ? 1.08 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isDragging)
    }

    private func tickDotsOverlay(totalWidth: CGFloat) -> some View {
        HStack {
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 3.5, height: 3.5)
                if index < 4 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, thumbWidth / 2)
    }

    private func updateValue(dragX: CGFloat, availableWidth: CGFloat) {
        guard availableWidth > 0 else { return }
        let rawFraction = (dragX - (thumbWidth / 2)) / availableWidth
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
