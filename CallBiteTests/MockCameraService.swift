//
//  MockCameraService.swift
//  CallBiteTests
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import AVFoundation
@testable import CallBite
import Combine
import UIKit

final class MockCameraService: CameraServiceProtocol {
    let captureSession = AVCaptureSession()

    var frameAnalysisPublisher: AnyPublisher<CameraFrameAnalysis, Never> {
        frameAnalysisSubject.eraseToAnyPublisher()
    }

    var status: AVAuthorizationStatus = .authorized
    var isSessionStarted = false
    var isSessionStopped = false
    var supportsFlash = true
    var isTorchEnabled = false

    private let frameAnalysisSubject = PassthroughSubject<CameraFrameAnalysis, Never>()

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
        isSessionStopped = false
    }

    func stopSession() {
        isSessionStopped = true
        isSessionStarted = false
    }

    func setTorchEnabled(_ isEnabled: Bool) async throws {
        isTorchEnabled = isEnabled
    }

    func capturePhoto() async throws -> UIImage {
        UIImage()
    }

    func sendFrameAnalysis(_ analysis: CameraFrameAnalysis) {
        frameAnalysisSubject.send(analysis)
    }
}
