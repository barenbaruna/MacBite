//
//  CameraMotionSample.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 12/09/26.
//

import Foundation

struct CameraMotionSample: Equatable, Sendable {
    let angleFromTable: Double
    let rotationRate: Double
    let timestamp: TimeInterval
}
