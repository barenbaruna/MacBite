//
//  RingGeometry.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Geometric representation of the calorie progress ring for synchronizing animation trajectories.
public struct RingGeometry: Equatable, Sendable {
    public var center: CGPoint = .zero
    public var radius: CGFloat = 105.0

    public var apex: CGPoint {
        CGPoint(x: center.x, y: center.y - radius)
    }

    public func point(forProgress progress: Double) -> CGPoint {
        let angleInDegrees = -90.0 + progress * 360.0
        let angleInRadians = angleInDegrees * .pi / 180.0
        return CGPoint(
            x: center.x + radius * CGFloat(cos(angleInRadians)),
            y: center.y + radius * CGFloat(sin(angleInRadians))
        )
    }

    public init(center: CGPoint = .zero, radius: CGFloat = 105.0) {
        self.center = center
        self.radius = radius
    }
}

/// PreferenceKey to dynamically read the layout center and radius of the progress ring.
public struct RingGeometryPreferenceKey: PreferenceKey {
    public static var defaultValue: RingGeometry = RingGeometry()

    public static func reduce(value: inout RingGeometry, nextValue: () -> RingGeometry) {
        let next = nextValue()
        if next.center != .zero {
            value = next
        }
    }
}
