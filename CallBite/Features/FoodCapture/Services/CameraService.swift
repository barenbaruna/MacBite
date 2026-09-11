//
//  CameraService.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@preconcurrency import AVFoundation
import Combine
import UIKit

final class CameraService: NSObject, CameraServiceProtocol,
    AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    let captureSession = AVCaptureSession()

    var frameAnalysisPublisher: AnyPublisher<CameraFrameAnalysis, Never> {
        frameAnalysisSubject.eraseToAnyPublisher()
    }

    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.callbite.camera.session")
    private let frameAnalysisQueue = DispatchQueue(
        label: "com.callbite.camera.analysis",
        qos: .userInitiated
    )
    private let frameAnalyzer: CameraFrameAnalyzing
    private let frameAnalysisSubject = PassthroughSubject<CameraFrameAnalysis, Never>()
    private var isConfigured = false
    private var supportsFlash = false
    private var cameraDevice: AVCaptureDevice?
    private var photoCaptureProcessor: PhotoCaptureProcessor?
    private var lastAnalyzedFrameTime = CMTime.invalid

    init(frameAnalyzer: CameraFrameAnalyzing = CameraFrameAnalyzer()) {
        self.frameAnalyzer = frameAnalyzer
        super.init()
    }

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
        let photoOutput = photoOutput
        let videoOutput = videoOutput

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

                    try self.configureCaptureSession(
                        session,
                        camera: camera,
                        photoOutput: photoOutput,
                        videoOutput: videoOutput
                    )
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

    private func configureCaptureSession(
        _ session: AVCaptureSession,
        camera: AVCaptureDevice,
        photoOutput: AVCapturePhotoOutput,
        videoOutput: AVCaptureVideoDataOutput
    ) throws {
        let input = try AVCaptureDeviceInput(device: camera)
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .photo

        guard session.canAddInput(input),
              session.canAddOutput(photoOutput),
              session.canAddOutput(videoOutput) else {
            throw CameraServiceError.configurationFailed
        }

        session.addInput(input)
        session.addOutput(photoOutput)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        videoOutput.setSampleBufferDelegate(self, queue: frameAnalysisQueue)
        session.addOutput(videoOutput)
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

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let frameTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if lastAnalyzedFrameTime.isValid {
            let elapsed = CMTimeGetSeconds(frameTime - lastAnalyzedFrameTime)
            guard elapsed >= CameraGuidanceThresholds.frameAnalysisInterval else { return }
        }
        lastAnalyzedFrameTime = frameTime

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let analysis = frameAnalyzer.analyze(pixelBuffer: pixelBuffer)
        frameAnalysisSubject.send(analysis)
    }
}
