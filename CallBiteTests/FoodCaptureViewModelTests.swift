//
//  FoodCaptureViewModelTests.swift
//  CallBiteTests
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

@testable import CallBite
import CoreGraphics
import Testing
import UIKit

@Suite("FoodCaptureViewModel Tests")
struct FoodCaptureViewModelTests {
    @Test("Camera guide is shown once before camera preparation")
    @MainActor
    func showsGuideBeforePreparingCamera() async {
        let cameraService = MockCameraService()
        let guideStore = MockCameraGuideStore(hasSeenCameraGuide: false)
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            motionService: MockMotionService(),
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
            motionService: MockMotionService(),
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
            motionService: MockMotionService(),
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
        let motionService = MockMotionService()
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            motionService: motionService,
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        await viewModel.prepareCamera()
        await satisfyCaptureChecks(
            viewModel: viewModel,
            cameraService: cameraService,
            motionService: motionService
        )

        await viewModel.capturePhoto()

        #expect(viewModel.state == .captured)
        #expect(viewModel.capturedImage != nil)
        #expect(cameraService.isSessionStopped)
    }

    @Test("Retake returns from captured photo to live camera")
    @MainActor
    func retakeReturnsToLiveCamera() async {
        let cameraService = MockCameraService()
        let motionService = MockMotionService()
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            motionService: motionService,
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        await viewModel.prepareCamera()
        await satisfyCaptureChecks(
            viewModel: viewModel,
            cameraService: cameraService,
            motionService: motionService
        )
        await viewModel.capturePhoto()

        await viewModel.retakePhoto()

        #expect(viewModel.capturedImage == nil)
        #expect(viewModel.state == .live)
        #expect(!viewModel.isCaptureReady)
    }

    @Test("Shutter uses the three visible quality checks")
    @MainActor
    func enablesShutterAfterAllChecksPass() async {
        let cameraService = MockCameraService()
        let motionService = MockMotionService()
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            motionService: motionService,
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        await viewModel.prepareCamera()

        #expect(!viewModel.isCaptureReady)

        cameraService.sendFrameAnalysis(
            CameraFrameAnalysis(
                brightness: 0.50,
                subjectBounds: nil,
                portraitFrameWidth: 1_080,
                portraitFrameHeight: 1_920
            )
        )
        motionService.sendMotionSample(
            CameraMotionSample(
                angleFromTable: 45,
                rotationRate: 0.10,
                timestamp: 100
            )
        )
        motionService.sendMotionSample(
            CameraMotionSample(
                angleFromTable: 45,
                rotationRate: 0.10,
                timestamp: 100.5
            )
        )
        await Task.yield()
        await Task.yield()

        #expect(viewModel.positionGuidance == .placeMeal)
        #expect(viewModel.isCaptureReady)
    }

    @MainActor
    private func satisfyCaptureChecks(
        viewModel: FoodCaptureViewModel,
        cameraService: MockCameraService,
        motionService: MockMotionService
    ) async {
        let viewportSize = CGSize(width: 402, height: 896)
        let layout = CameraGuidanceLayout(viewportSize: viewportSize)
        viewModel.updatePreviewLayout(
            viewportSize: viewportSize,
            guideFrame: layout.guideFrame
        )
        cameraService.sendFrameAnalysis(
            CameraFrameAnalysis(
                brightness: 0.50,
                subjectBounds: CameraSubjectBounds(
                    x: 0.274,
                    y: 0.291,
                    width: 0.452,
                    height: 0.254
                ),
                portraitFrameWidth: 1_080,
                portraitFrameHeight: 1_920
            )
        )
        motionService.sendMotionSample(
            CameraMotionSample(
                angleFromTable: 45,
                rotationRate: 0.10,
                timestamp: 100
            )
        )
        motionService.sendMotionSample(
            CameraMotionSample(
                angleFromTable: 45,
                rotationRate: 0.10,
                timestamp: 100.5
            )
        )

        await Task.yield()
        await Task.yield()
    }

    @Test("Image is cropped to guide scope aspect ratio")
    @MainActor
    func cropsImageToGuideScope() {
        let viewModel = FoodCaptureViewModel(
            cameraService: MockCameraService(),
            motionService: MockMotionService(),
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )
        let viewport = CGSize(width: 400, height: 800)
        let guide = CGRect(x: 50, y: 200, width: 300, height: 300)
        viewModel.updatePreviewLayout(viewportSize: viewport, guideFrame: guide)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1000, height: 1500))
        let testImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1000, height: 1500))
        }

        let cropped = viewModel.cropImageToGuideScope(testImage)
        #expect(abs(cropped.size.width - cropped.size.height) < 1.0)
    }

    @Test("Gallery image is cropped to center square")
    @MainActor
    func cropsGalleryImageToCenterSquare() {
        let viewModel = FoodCaptureViewModel(
            cameraService: MockCameraService(),
            motionService: MockMotionService(),
            guideStore: MockCameraGuideStore(hasSeenCameraGuide: true)
        )

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 800))
        let rectangularImage = renderer.image { ctx in
            UIColor.green.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1200, height: 800))
        }

        let cropped = viewModel.cropToCenterSquare(image: rectangularImage)
        #expect(cropped.size.width == 800)
        #expect(cropped.size.height == 800)
    }
}
