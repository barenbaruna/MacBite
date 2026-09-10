//
//  OrbitingProgressModifier.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Animatable modifier moving a view along a circular orbital path based on progress.
public struct OrbitingProgressModifier: AnimatableModifier {
    public var progress: Double
    public var center: CGPoint
    public var radius: CGFloat

    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    public init(progress: Double, center: CGPoint, radius: CGFloat) {
        self.progress = progress
        self.center = center
        self.radius = radius
    }

    public func body(content: Content) -> some View {
        let angleInDegrees = -90.0 + progress * 360.0
        let angleInRadians = angleInDegrees * .pi / 180.0
        let posX = center.x + radius * CGFloat(cos(angleInRadians))
        let posY = center.y + radius * CGFloat(sin(angleInRadians))

        return content
            .position(x: posX, y: posY)
    }
}
