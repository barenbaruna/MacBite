//
//  CameraService.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@preconcurrency import AVFoundation
import UIKit

final class CameraService: CameraServiceProtocol, @unchecked Sendable {
    let captureSession = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.callbite.camera.session")
    private var isConfigured = false
    private var supportsFlash = false
    private var cameraDevice: AVCaptureDevice?
    private var photoCaptureProcessor: PhotoCaptureProcessor?

    func authorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func configure() async throws -> Bool {
        if isConfigured {
            return supportsFlash
        }

        let session = captureSession
        let output = photoOutput

        let configuredCamera = try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                do {
                    guard let camera = AVCaptureDevice.default(
                        .builtInWideAngleCamera,
                        for: .video,
                        position: .back
                    ) else {
                        throw CameraServiceError.cameraUnavailable
                    }

                    let input = try AVCaptureDeviceInput(device: camera)
                    session.beginConfiguration()
                    defer { session.commitConfiguration() }
                    session.sessionPreset = .photo

                    guard session.canAddInput(input), session.canAddOutput(output) else {
                        throw CameraServiceError.configurationFailed
                    }

                    session.addInput(input)
                    session.addOutput(output)
                    continuation.resume(returning: camera)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        cameraDevice = configuredCamera
        supportsFlash = configuredCamera.hasTorch
        isConfigured = true
        return supportsFlash
    }

    func startSession() async {
        guard isConfigured, !captureSession.isRunning else { return }
        let session = captureSession
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                session.startRunning()
                continuation.resume()
            }
        }
    }

    func stopSession() {
        let session = captureSession
        let device = cameraDevice
        sessionQueue.async {
            if let device, device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = .off
                    device.unlockForConfiguration()
                } catch {
                    // The session is still stopped even if the torch cannot be reset.
                }
            }

            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    func setTorchEnabled(_ isEnabled: Bool) async throws {
        guard let cameraDevice, cameraDevice.hasTorch else {
            throw CameraServiceError.cameraUnavailable
        }

        try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async {
                do {
                    try cameraDevice.lockForConfiguration()
                    cameraDevice.torchMode = isEnabled ? .on : .off
                    cameraDevice.unlockForConfiguration()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func capturePhoto() async throws -> UIImage {
        let output = photoOutput
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .balanced

        return try await withCheckedThrowingContinuation { continuation in
            let processor = PhotoCaptureProcessor { result in
                continuation.resume(with: result)
            }

            photoCaptureProcessor = processor
            sessionQueue.async {
                output.capturePhoto(with: settings, delegate: processor)
            }
        }
    }
}
