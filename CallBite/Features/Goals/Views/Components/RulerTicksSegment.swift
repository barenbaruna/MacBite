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
    let activeRange: ClosedRange<CGFloat>?
    let accentColor: Color
    let boundaryEdge: RulerBoundaryEdge

    private let desiredSpacing: CGFloat = 11.5
    private let tickWidth: CGFloat = 2.5
    private let majorTickHeight: CGFloat = 40.0
    private let minorTickHeight: CGFloat = 24.0

    var body: some View {
        Canvas { context, size in
            drawActiveBackground(context: context, size: size)
            drawTicks(context: context, size: size)
            drawBoundaryMarker(context: context, size: size)
        }
        .frame(width: width, height: height)
        .animation(.smooth(duration: 0.15), value: activeRange)
    }

    // MARK: - Drawing Helpers

    private func drawActiveBackground(context: GraphicsContext, size: CGSize) {
        guard let active = activeRange else { return }

        let startX = boundaryEdge == .trailing ? size.width : 0
        let endX = boundaryEdge == .trailing ? active.lowerBound : active.upperBound
        let rect = CGRect(
            x: min(startX, endX),
            y: (size.height - majorTickHeight) / 2,
            width: max(0, abs(endX - startX)),
            height: majorTickHeight
        )
        let gradient = Gradient(colors: [
            accentColor.opacity(0.22),
            accentColor.opacity(0.04)
        ])
        context.fill(
            Path(roundedRect: rect, cornerRadius: 4),
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: startX, y: size.height / 2),
                endPoint: CGPoint(x: endX, y: size.height / 2)
            )
        )
    }

    private func drawTicks(context: GraphicsContext, size: CGSize) {
        let count = max(4, Int((size.width / desiredSpacing).rounded()))
        let actualSpacing = size.width / CGFloat(count)

        for tickIndex in 0..<count {
            let currentX = (CGFloat(tickIndex) + 0.5) * actualSpacing
            let isMajor = tickIndex % 2 == 0
            let currentTickHeight = isMajor ? majorTickHeight : minorTickHeight
            let tickY = (size.height - currentTickHeight) / 2

            let isTickActive = activeRange?.contains(currentX) ?? false
            let tickColor = isTickActive ? accentColor : Color.white.opacity(0.18)
            let rect = CGRect(
                x: currentX - (tickWidth / 2),
                y: tickY,
                width: tickWidth,
                height: currentTickHeight
            )
            let path = Path(roundedRect: rect, cornerRadius: tickWidth / 2)

            context.fill(path, with: .color(tickColor))

            if isTickActive {
                var glowContext = context
                glowContext.addFilter(.blur(radius: 2.0))
                glowContext.fill(path, with: .color(accentColor.opacity(0.45)))
            }
        }
    }

    private func drawBoundaryMarker(context: GraphicsContext, size: CGSize) {
        let boundaryX = boundaryEdge == .trailing ? (size.width - tickWidth / 2) : (tickWidth / 2)
        let isBoundaryActive = activeRange != nil
        let boundaryColor = isBoundaryActive ? accentColor : Color.white.opacity(0.28)
        let boundaryRect = CGRect(
            x: boundaryX - (tickWidth / 2),
            y: (size.height - majorTickHeight) / 2,
            width: tickWidth,
            height: majorTickHeight
        )
        let boundaryPath = Path(roundedRect: boundaryRect, cornerRadius: tickWidth / 2)
        context.fill(boundaryPath, with: .color(boundaryColor))

        if isBoundaryActive {
            var glowContext = context
            glowContext.addFilter(.blur(radius: 2.5))
            glowContext.fill(boundaryPath, with: .color(accentColor.opacity(0.6)))
        }
    }
}
