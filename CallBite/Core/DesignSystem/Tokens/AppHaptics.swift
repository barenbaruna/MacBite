//
//  AppHaptics.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 10/09/26.
//

import UIKit

/// Taptic Engine haptic feedback generator aligned with Apple HIG guidelines.
enum AppHaptics {
    /// Triggered when the user adjusts continuous sliders or switches selections.
    @MainActor
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Triggered on primary CTA actions and capture button taps.
    @MainActor
    static func primaryAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Triggered when a food item is successfully logged or saved.
    @MainActor
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Triggered on warning thresholds or over-target events.
    @MainActor
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}
