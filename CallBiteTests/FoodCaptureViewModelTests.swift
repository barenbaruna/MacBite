//
//  FoodCaptureViewModelTests.swift
//  CallBiteTests
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@testable import CallBite
import Testing

@Suite("FoodCaptureViewModel Tests")
struct FoodCaptureViewModelTests {
    @Test("Camera guide is shown once before camera preparation")
    @MainActor
    func showsGuideBeforePreparingCamera() async {
        let cameraService = MockCameraService()
        let guideStore = MockCameraGuideStore(hasSeenCameraGuide: false)
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            guideStore: guideStore
        )

        await viewModel.prepareCamera()

        #expect(viewModel.isGuidePresented)
        #expect(!cameraService.isSessionStarted)

        viewModel.dismissGuide()
        await viewModel.prepareCamera()

        #expect(guideStore.hasSeenCameraGuide)
        #expect(!viewModel.isGuidePresented)
        #expect(cameraService.isSessionStarted)
        #expect(viewModel.state == .live)
    }

    @Test("Seen camera guide stays hidden")
    @MainActor
    func keepsSeenGuideHidden() {
        let viewModel = FoodCaptureViewModel(
            cameraService: MockCameraService(),
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )

        #expect(!viewModel.isGuidePresented)
    }

    @Test("Flash controls the camera torch")
    @MainActor
    func togglesCameraTorch() async {
        let cameraService = MockCameraService()
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        await viewModel.prepareCamera()

        await viewModel.toggleFlash()

        #expect(viewModel.isFlashEnabled)
        #expect(cameraService.isTorchEnabled)
    }

    @Test("Camera capture presents the captured photo state")
    @MainActor
    func presentsCapturedCameraPhoto() async {
        let cameraService = MockCameraService()
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        await viewModel.prepareCamera()

        await viewModel.capturePhoto()

        #expect(viewModel.state == .captured)
        #expect(viewModel.capturedImage != nil)
        #expect(cameraService.isSessionStopped)
    }

    @Test("Retake returns from captured photo to live camera")
    @MainActor
    func retakeReturnsToLiveCamera() async {
        let viewModel = FoodCaptureViewModel(
            cameraService: MockCameraService(),
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        await viewModel.prepareCamera()
        await viewModel.capturePhoto()

        await viewModel.retakePhoto()

        #expect(viewModel.capturedImage == nil)
        #expect(viewModel.state == .live)
    }
}
