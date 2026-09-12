//
//  FoodCaptureView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import PhotosUI
import SwiftUI

struct FoodCaptureView: View {
    @ObservedObject private var viewModel: FoodCaptureViewModel
    @State private var selectedPhoto: PhotosPickerItem?

    let onDismiss: () -> Void
    let onUsePhoto: (UIImage) -> Void

    init(
        viewModel: FoodCaptureViewModel,
        onDismiss: @escaping () -> Void,
        onUsePhoto: @escaping (UIImage) -> Void
    ) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        self.onUsePhoto = onUsePhoto
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = CameraGuidanceLayout(viewportSize: geometry.size)

            cameraExperience(layout: layout)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
            .overlay(alignment: .bottom) {
                capturedPhotoActions
            }
            .onAppear {
                updatePreviewLayout(size: geometry.size, layout: layout)
            }
            .onChange(of: geometry.size) { _, newSize in
                let updatedLayout = CameraGuidanceLayout(viewportSize: newSize)
                updatePreviewLayout(size: newSize, layout: updatedLayout)
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.prepareCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else { return }
            Task {
                if let data = try? await newPhoto.loadTransferable(type: Data.self) {
                    viewModel.selectPhoto(data: data)
                }
                selectedPhoto = nil
            }
        }
        .alert(
            "Unable to Take Photo",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
    }

    private func cameraExperience(layout: CameraGuidanceLayout) -> some View {
        ZStack {
            AppColor.dark950
            cameraContent
            liveExperience(layout: layout)
            firstUseGuide
        }
    }

    @ViewBuilder
    private func liveExperience(layout: CameraGuidanceLayout) -> some View {
        if viewModel.state != .captured {
            AppColor.cameraPreviewScrim

            if viewModel.state == .live || viewModel.state == .capturing {
                CameraGuidanceOverlay(
                    layout: layout,
                    guidance: viewModel.positionGuidance,
                    checks: viewModel.qualityChecks
                )
            }

            liveCameraControls
        }
    }

    @ViewBuilder
    private var capturedPhotoActions: some View {
        if viewModel.state == .captured {
            CapturedPhotoActionsView(
                onRetake: retakePhoto,
                onUsePhoto: usePhoto
            )
            .zIndex(1)
        }
    }

    @ViewBuilder
    private var firstUseGuide: some View {
        if viewModel.isGuidePresented {
            CameraGuideView {
                viewModel.dismissGuide()
                Task {
                    await viewModel.prepareCamera()
                }
            }
        }
    }

    @ViewBuilder
    private var cameraContent: some View {
        if let capturedImage = viewModel.capturedImage {
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityLabel("Captured food photo")
        } else {
            CameraPreview(captureSession: viewModel.captureSession)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)

            cameraStatus
        }
    }

    @ViewBuilder
    private var cameraStatus: some View {
        switch viewModel.state {
        case .preparing:
            ProgressView("Preparing Camera")
                .tint(AppColor.white)
                .foregroundStyle(AppColor.white)
        case .permissionDenied:
            ContentUnavailableView(
                "Camera Access Needed",
                systemImage: "camera.fill",
                description: Text("Allow camera access in Settings to take a food photo.")
            )
            .foregroundStyle(AppColor.white)
        case .unavailable:
            ContentUnavailableView(
                "Camera Unavailable",
                systemImage: "camera.slash.fill",
                description: Text("Choose a food photo from your gallery instead.")
            )
            .foregroundStyle(AppColor.white)
        case .live, .capturing, .captured:
            EmptyView()
        }
    }

    private var liveCameraControls: some View {
        VStack {
            cameraTopBar

            Spacer()

            cameraBottomControls
        }
    }

    private var cameraTopBar: some View {
        HStack {
            cameraControlButton(
                systemImage: "xmark",
                accessibilityLabel: "Close Camera",
                action: onDismiss
            )
            Spacer()
        }
        .padding(.top, AppSpacing.cameraCloseTopInset)
        .padding(.horizontal, AppSpacing.cameraCloseHorizontalInset)
    }

    private var cameraBottomControls: some View {
        HStack {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                CameraControlLabel(
                    systemImage: "photo",
                    accessibilityLabel: "Choose from Gallery"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose from Gallery")

            Spacer()

            CaptureButton(isEnabled: viewModel.isCaptureReady) {
                AppHaptics.primaryAction()
                Task {
                    await viewModel.capturePhoto()
                }
            }

            Spacer()

            cameraControlButton(
                systemImage: viewModel.isFlashEnabled ? "bolt.fill" : "bolt.slash.fill",
                accessibilityLabel: viewModel.isFlashEnabled ? "Turn Flash Off" : "Turn Flash On"
            ) {
                AppHaptics.selectionChanged()
                Task {
                    await viewModel.toggleFlash()
                }
            }
            .disabled(!viewModel.isFlashAvailable || viewModel.state != .live)
        }
        .padding(.horizontal, AppSpacing.cameraBottomControlsHorizontalInset)
        .padding(.bottom, AppSpacing.cameraBottomControlsInset)
    }

    private func cameraControlButton(
        systemImage: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            CameraControlLabel(
                systemImage: systemImage,
                accessibilityLabel: accessibilityLabel
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func updatePreviewLayout(
        size: CGSize,
        layout: CameraGuidanceLayout
    ) {
        viewModel.updatePreviewLayout(
            viewportSize: size,
            guideFrame: layout.guideFrame
        )
    }

    private func retakePhoto() {
        Task {
            await viewModel.retakePhoto()
        }
    }

    private func usePhoto() {
        guard let image = viewModel.capturedImage else { return }
        onUsePhoto(image)
    }
}
