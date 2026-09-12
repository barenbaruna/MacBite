//
//  FoodCaptureViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import AVFoundation
import Combine
import Foundation
import UIKit

@MainActor
final class FoodCaptureViewModel: ObservableObject {
    @Published private(set) var state: CameraState = .preparing
    @Published private(set) var capturedImage: UIImage?
    @Published private(set) var isFlashEnabled = false
    @Published private(set) var isFlashAvailable = false
    @Published private(set) var isGuidePresented: Bool
    @Published private(set) var errorMessage: String?
    @Published private(set) var qualityChecks = CameraQualityChecks()
    @Published private(set) var positionGuidance: CameraPositionGuidance = .placeMeal

    let captureSession: AVCaptureSession

    var isCaptureReady: Bool {
        state == .live && qualityChecks.areCaptureChecksPassing
    }

    private let cameraService: CameraServiceProtocol
    private let motionService: MotionServiceProtocol
    private let guideStore: CameraGuideStoreProtocol
    private let guidanceEvaluator = CameraGuidanceEvaluator()
    private var cancellables = Set<AnyCancellable>()
    private var viewportSize = CGSize.zero
    private var guideFrame = CGRect.zero
    private var lastFrameAnalysis: CameraFrameAnalysis?
    private var steadyStartTime: TimeInterval?

    init(
        cameraService: CameraServiceProtocol,
        motionService: MotionServiceProtocol,
        guideStore: CameraGuideStoreProtocol
    ) {
        self.cameraService = cameraService
        self.motionService = motionService
        self.guideStore = guideStore
        captureSession = cameraService.captureSession
        isGuidePresented = !guideStore.hasSeenCameraGuide
        observeGuidanceInputs()
    }

    func prepareCamera() async {
        guard state != .captured, !isGuidePresented else { return }

        state = .preparing
        errorMessage = nil

        switch cameraService.authorizationStatus() {
        case .authorized:
            await configureAndStartCamera()
        case .notDetermined:
            let isGranted = await cameraService.requestAccess()
            if isGranted {
                await configureAndStartCamera()
            } else {
                state = .permissionDenied
            }
        case .denied, .restricted:
            state = .permissionDenied
        @unknown default:
            state = .unavailable
        }
    }

    func stopCamera() {
        cameraService.stopSession()
        motionService.stopUpdates()
    }

    func dismissGuide() {
        guideStore.markCameraGuideAsSeen()
        isGuidePresented = false
    }

    func dismissError() {
        errorMessage = nil
    }

    func toggleFlash() async {
        guard isFlashAvailable else { return }

        let shouldEnableFlash = !isFlashEnabled
        do {
            try await cameraService.setTorchEnabled(shouldEnableFlash)
            isFlashEnabled = shouldEnableFlash
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func capturePhoto() async {
        guard isCaptureReady else { return }

        state = .capturing
        do {
            let rawImage = try await cameraService.capturePhoto()
            let croppedImage = cropImageToGuideScope(rawImage)
            presentCapturedImage(croppedImage)
        } catch {
            errorMessage = error.localizedDescription
            state = .live
        }
    }

    func selectPhoto(data: Data) {
        guard let rawImage = UIImage(data: data) else {
            errorMessage = CameraServiceError.invalidPhotoData.localizedDescription
            return
        }

        let croppedImage = cropToCenterSquare(image: rawImage)
        presentCapturedImage(croppedImage)
    }

    func cropImageToGuideScope(_ image: UIImage) -> UIImage {
        guard image.size.width > 0, image.size.height > 0 else {
            return image
        }

        guard viewportSize.width > 0,
              viewportSize.height > 0,
              guideFrame.width > 0,
              guideFrame.height > 0 else {
            return cropToCenterSquare(image: image)
        }

        let scale = max(viewportSize.width / image.size.width, viewportSize.height / image.size.height)
        guard scale > 0 else {
            return cropToCenterSquare(image: image)
        }

        let renderedWidth = image.size.width * scale
        let renderedHeight = image.size.height * scale
        let originX = (viewportSize.width - renderedWidth) / 2.0
        let originY = (viewportSize.height - renderedHeight) / 2.0

        let cropX = (guideFrame.minX - originX) / scale
        let cropY = (guideFrame.minY - originY) / scale
        let cropWidth = guideFrame.width / scale
        let cropHeight = guideFrame.height / scale

        let clampedX = max(0, min(cropX, image.size.width))
        let clampedY = max(0, min(cropY, image.size.height))
        let clampedWidth = max(0, min(cropWidth, image.size.width - clampedX))
        let clampedHeight = max(0, min(cropHeight, image.size.height - clampedY))

        guard clampedWidth > 10, clampedHeight > 10 else {
            return cropToCenterSquare(image: image)
        }

        let cropRect = CGRect(x: clampedX, y: clampedY, width: clampedWidth, height: clampedHeight)
        return renderCroppedImage(image, in: cropRect)
    }

    func cropToCenterSquare(image: UIImage) -> UIImage {
        let side = min(image.size.width, image.size.height)
        guard side > 0 else { return image }
        let rect = CGRect(
            x: (image.size.width - side) / 2.0,
            y: (image.size.height - side) / 2.0,
            width: side,
            height: side
        )
        return renderCroppedImage(image, in: rect)
    }

    private func renderCroppedImage(_ image: UIImage, in rect: CGRect) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        return renderer.image { _ in
            image.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        }
    }

    func retakePhoto() async {
        capturedImage = nil
        resetGuidance()
        motionService.startUpdates()
        state = .live
    }

    func updatePreviewLayout(viewportSize: CGSize, guideFrame: CGRect) {
        self.viewportSize = viewportSize
        self.guideFrame = guideFrame

        if let lastFrameAnalysis {
            applyFrameAnalysis(lastFrameAnalysis)
        }
    }

    private func configureAndStartCamera() async {
        do {
            isFlashAvailable = try await cameraService.configure()
            await cameraService.startSession()
            motionService.startUpdates()
            state = .live
        } catch {
            errorMessage = error.localizedDescription
            state = .unavailable
        }
    }

    private func presentCapturedImage(_ image: UIImage) {
        cameraService.stopSession()
        motionService.stopUpdates()
        isFlashEnabled = false
        capturedImage = image
        state = .captured
    }

    private func observeGuidanceInputs() {
        cameraService.frameAnalysisPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] analysis in
                self?.applyFrameAnalysis(analysis)
            }
            .store(in: &cancellables)

        motionService.motionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sample in
                self?.applyMotionSample(sample)
            }
            .store(in: &cancellables)
    }

    private func applyFrameAnalysis(_ analysis: CameraFrameAnalysis) {
        lastFrameAnalysis = analysis

        var updatedChecks = qualityChecks
        updatedChecks.hasAcceptableLighting =
            CameraGuidanceThresholds.minimumBrightness...CameraGuidanceThresholds.maximumBrightness
            ~= analysis.brightness

        let positionEvaluation = guidanceEvaluator.evaluatePosition(
            analysis: analysis,
            viewportSize: viewportSize,
            guideFrame: guideFrame
        )
        qualityChecks = updatedChecks
        positionGuidance = positionEvaluation.guidance
    }

    private func applyMotionSample(_ sample: CameraMotionSample) {
        let nearestAcceptedAngle = CameraGuidanceThresholds.acceptedAngles.min {
            abs(sample.angleFromTable - $0) < abs(sample.angleFromTable - $1)
        } ?? 90
        let angleDifference = sample.angleFromTable - nearestAcceptedAngle

        var updatedChecks = qualityChecks
        updatedChecks.hasAcceptableAngle =
            abs(angleDifference) <= CameraGuidanceThresholds.angleTolerance
        if sample.rotationRate <= CameraGuidanceThresholds.maximumRotationRate {
            if steadyStartTime == nil {
                steadyStartTime = sample.timestamp
            }

            if let steadyStartTime {
                updatedChecks.isSteady =
                    sample.timestamp - steadyStartTime
                    >= CameraGuidanceThresholds.steadyDuration
            }
        } else {
            steadyStartTime = nil
            updatedChecks.isSteady = false
        }

        qualityChecks = updatedChecks
    }

    private func resetGuidance() {
        qualityChecks = CameraQualityChecks()
        positionGuidance = .placeMeal
        lastFrameAnalysis = nil
        steadyStartTime = nil
    }
}
