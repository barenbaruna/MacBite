//
//  FoodCaptureViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Combine
import AVFoundation
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

    let captureSession: AVCaptureSession

    private let cameraService: CameraServiceProtocol
    private let guideStore: CameraGuideStoreProtocol

    init(
        cameraService: CameraServiceProtocol,
        guideStore: CameraGuideStoreProtocol
    ) {
        self.cameraService = cameraService
        self.guideStore = guideStore
        captureSession = cameraService.captureSession
        isGuidePresented = !guideStore.hasSeenCameraGuide
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
        guard state == .live else { return }

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
        state = .preparing
        await prepareCamera()
    }

    private func configureAndStartCamera() async {
        do {
            isFlashAvailable = try await cameraService.configure()
            await cameraService.startSession()
            state = .live
        } catch {
            errorMessage = error.localizedDescription
            state = .unavailable
        }
    }

    private func presentCapturedImage(_ image: UIImage) {
        cameraService.stopSession()
        isFlashEnabled = false
        capturedImage = image
        state = .captured
    }
}
