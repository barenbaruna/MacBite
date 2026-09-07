//
//  OrbitingProgressModifier.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

// MARK: - Ring Geometry Model
struct RingGeometry: Equatable {
    var center: CGPoint = .zero
    var radius: CGFloat = 105.0

    var apex: CGPoint {
        CGPoint(x: center.x, y: center.y - radius)
    }
}

// MARK: - PreferenceKey for Dynamic Ring Tracking
struct RingGeometryPreferenceKey: PreferenceKey {
    static var defaultValue: RingGeometry = RingGeometry()

    static func reduce(value: inout RingGeometry, nextValue: () -> RingGeometry) {
        let next = nextValue()
        if next.center != .zero {
            value = next
        }
    }
}

// MARK: - Orbiting Progress Animatable Modifier (Polar Coordinates at 120Hz)
struct OrbitingProgressModifier: AnimatableModifier {
    var progress: Double
    var center: CGPoint
    var radius: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let angleInDegrees = -90.0 + progress * 360.0
        let angleInRadians = angleInDegrees * .pi / 180.0
        let posX = center.x + radius * CGFloat(cos(angleInRadians))
        let posY = center.y + radius * CGFloat(sin(angleInRadians))

        content
            .position(x: posX, y: posY)
    }
}
