//
//  RulerTicksSegment.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Boundary edge for ruler segments facing the middle recommended zone.
enum RulerBoundaryEdge {
    case leading
    case trailing
}

/// Borderless ruler ticks subview rendering smoothed, proportional tick marks and dynamic illumination.
struct RulerTicksSegment: View {
    let width: CGFloat
    let height: CGFloat
    let tickCount: Int
    let activeRange: ClosedRange<CGFloat>?
    let accentColor: Color
    let boundaryEdge: RulerBoundaryEdge

    private let tickWidth: CGFloat = 2.0
    private let tickHeight: CGFloat = 38.0
    private let cardCornerRadius: CGFloat = 8.0
    private let inset: CGFloat = 6.0

    init(
        width: CGFloat,
        height: CGFloat,
        tickCount: Int = 10,
        activeRange: ClosedRange<CGFloat>?,
        accentColor: Color,
        boundaryEdge: RulerBoundaryEdge
    ) {
        self.width = width
        self.height = height
        self.tickCount = max(4, tickCount)
        self.activeRange = activeRange
        self.accentColor = accentColor
        self.boundaryEdge = boundaryEdge
    }

    var body: some View {
        Canvas { context, size in
            drawCardBackground(context: context, size: size)
            drawActiveBackground(context: context, size: size)
            drawTicks(context: context, size: size)
        }
        .frame(width: width, height: height)
        .animation(.smooth(duration: 0.15), value: activeRange)
    }

    // MARK: - Drawing Helpers

    private func drawCardBackground(context: GraphicsContext, size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let cardRect = CGRect(
            x: 0,
            y: (size.height - tickHeight) / 2 - 4,
            width: size.width,
            height: tickHeight + 8
        )
        context.fill(
            Path(roundedRect: cardRect, cornerRadius: cardCornerRadius),
            with: .color(Color.white.opacity(0.06))
        )
    }

    private func drawActiveBackground(context: GraphicsContext, size: CGSize) {
        guard size.width > 0, size.height > 0, let active = activeRange else { return }

        let startX: CGFloat = boundaryEdge == .trailing ? size.width : 0
        let endX: CGFloat = boundaryEdge == .trailing ? active.lowerBound : active.upperBound
        let left = min(startX, endX)
        let right = max(startX, endX)
        let activeWidth = max(0, right - left)

        let rect = CGRect(
            x: left,
            y: (size.height - tickHeight) / 2 - 4,
            width: activeWidth,
            height: tickHeight + 8
        )
        let gradient = Gradient(colors: boundaryEdge == .trailing
            ? [accentColor.opacity(0.08), accentColor.opacity(0.35)]
            : [accentColor.opacity(0.35), accentColor.opacity(0.08)])

        context.fill(
            Path(roundedRect: rect, cornerRadius: cardCornerRadius),
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: left, y: size.height / 2),
                endPoint: CGPoint(x: right, y: size.height / 2)
            )
        )
    }

    private func drawTicks(context: GraphicsContext, size: CGSize) {
        guard size.width > (inset * 2), size.height > 0 else { return }

        let startX: CGFloat = inset
        let endX: CGFloat = size.width - inset
        let span = endX - startX
        let stepCount = max(1, tickCount - 1)

        for step in 0..<tickCount {
            let fraction = CGFloat(step) / CGFloat(stepCount)
            let currentX = startX + (fraction * span)
            let tickY = (size.height - tickHeight) / 2

            let isBoundaryTick = (boundaryEdge == .trailing && step == tickCount - 1) ||
                                 (boundaryEdge == .leading && step == 0)

            let isTickActive = activeRange?.contains(currentX) ?? false

            let tickColor: Color
            if isTickActive {
                tickColor = accentColor
            } else if isBoundaryTick {
                tickColor = Color.white.opacity(0.35)
            } else {
                tickColor = Color.white.opacity(0.18)
            }

            let rect = CGRect(
                x: currentX - (tickWidth / 2),
                y: tickY,
                width: tickWidth,
                height: tickHeight
            )
            let path = Path(roundedRect: rect, cornerRadius: tickWidth / 2)

            context.fill(path, with: .color(tickColor))

            if isTickActive {
                var glowContext = context
                glowContext.addFilter(.blur(radius: 2.5))
                glowContext.fill(path, with: .color(accentColor.opacity(0.6)))
            } else if isBoundaryTick {
                var glowContext = context
                glowContext.addFilter(.blur(radius: 1.5))
                glowContext.fill(path, with: .color(Color.white.opacity(0.2)))
            }
        }
    }
}
