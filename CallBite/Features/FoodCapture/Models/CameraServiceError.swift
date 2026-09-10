//
//  CameraServiceError.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import Foundation

enum CameraServiceError: LocalizedError {
    case cameraUnavailable
    case configurationFailed
    case invalidPhotoData

    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            "The camera is unavailable on this device."
        case .configurationFailed:
            "The camera could not be prepared."
        case .invalidPhotoData:
            "The captured photo could not be read."
        }
    }
}
