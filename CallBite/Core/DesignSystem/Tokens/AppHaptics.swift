//
//  AppHaptics.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import UIKit

enum AppHaptics {
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func primaryAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
