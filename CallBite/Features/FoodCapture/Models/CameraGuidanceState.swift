//
//  CameraGuidanceState.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import Foundation

enum CameraPositionGuidance: Equatable {
    case placeMeal
    case moveCloser
    case moveBack
    case centerPlate
    case ready
}

struct CameraQualityChecks: Equatable {
    var hasAcceptableLighting = false
    var hasAcceptableAngle = false
    var isSteady = false

    var areCaptureChecksPassing: Bool {
        hasAcceptableLighting
            && hasAcceptableAngle
            && isSteady
    }
}

enum CameraGuidanceThresholds {
    static let minimumBrightness = 0.25
    static let maximumBrightness = 0.85
    static let minimumSubjectCoverage = 0.30
    static let maximumSubjectCoverage = 0.85
    static let centeredRegionFraction = 0.30
    static let acceptedAngles = [45.0, 90.0]
    static let angleTolerance = 5.0
    static let maximumRotationRate = 0.15
    static let steadyDuration = 0.50
    static let frameAnalysisInterval = 0.25
}
