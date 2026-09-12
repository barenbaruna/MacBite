//
//  CameraFrameAnalysis.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import CoreGraphics
import Foundation

struct CameraSubjectBounds: Equatable, Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    var normalizedRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

struct CameraFrameAnalysis: Equatable, Sendable {
    let brightness: Double
    let subjectBounds: CameraSubjectBounds?
    let portraitFrameWidth: Double
    let portraitFrameHeight: Double
}
