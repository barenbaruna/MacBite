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
            let image = try await cameraService.capturePhoto()
            presentCapturedImage(image)
        } catch {
            errorMessage = error.localizedDescription
            state = .live
        }
    }

    func selectPhoto(data: Data) {
        guard let image = UIImage(data: data) else {
            errorMessage = CameraServiceError.invalidPhotoData.localizedDescription
            return
        }

        presentCapturedImage(image)
    }

    func retakePhoto() async {
        capturedImage = nil
        resetGuidance()
        state = .preparing
        await prepareCamera()
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
