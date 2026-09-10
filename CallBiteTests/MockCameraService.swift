//
//  MockCameraService.swift
//  CallBiteTests
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import AVFoundation
import UIKit
@testable import CallBite

final class MockCameraService: CameraServiceProtocol {
    let captureSession = AVCaptureSession()

    var status: AVAuthorizationStatus = .authorized
    var isSessionStarted = false
    var isSessionStopped = false
    var supportsFlash = true
    var isTorchEnabled = false

    func authorizationStatus() -> AVAuthorizationStatus {
        status
    }

    func requestAccess() async -> Bool {
        true
    }

    func configure() async throws -> Bool {
        supportsFlash
    }

    func startSession() async {
        isSessionStarted = true
    }

    func stopSession() {
        isSessionStopped = true
    }

    func setTorchEnabled(_ isEnabled: Bool) async throws {
        isTorchEnabled = isEnabled
    }

    func capturePhoto() async throws -> UIImage {
        UIImage()
    }
}
