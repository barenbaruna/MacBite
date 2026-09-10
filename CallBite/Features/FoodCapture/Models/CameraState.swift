//
//  CameraState.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

enum CameraState: Equatable {
    case preparing
    case live
    case capturing
    case captured
    case permissionDenied
    case unavailable
}
