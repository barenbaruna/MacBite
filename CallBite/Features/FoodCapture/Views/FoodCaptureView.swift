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

            cameraExperience(layout: layout, safeArea: geometry.safeAreaInsets)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
            .overlay(alignment: .bottom) {
                capturedPhotoActions(safeAreaBottom: geometry.safeAreaInsets.bottom)
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

    private func cameraExperience(layout: CameraGuidanceLayout, safeArea: EdgeInsets) -> some View {
        ZStack {
            AppColor.dark950
            cameraContent
            liveExperience(layout: layout, safeArea: safeArea)
            firstUseGuide
        }
    }

    @ViewBuilder
    private func liveExperience(layout: CameraGuidanceLayout, safeArea: EdgeInsets) -> some View {
        if viewModel.state != .captured {
            if viewModel.state == .live || viewModel.state == .capturing {
                guideFrameBlurMask(layout: layout)

                CameraGuidanceOverlay(
                    layout: layout,
                    guidance: viewModel.positionGuidance,
                    checks: viewModel.qualityChecks
                )
            } else {
                AppColor.cameraPreviewScrim
            }

            liveCameraControls(safeArea: safeArea)
        }
    }

    private func guideFrameBlurMask(layout: CameraGuidanceLayout) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Color.black.opacity(0.18)
        }
        .mask {
            InvertedCutoutShape(
                cutoutRect: layout.guideFrame,
                cornerRadius: AppSize.cameraSafeAreaCornerRadius
            )
            .fill(style: FillStyle(eoFill: true))
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func capturedPhotoActions(safeAreaBottom: CGFloat) -> some View {
        if viewModel.state == .captured {
            CapturedPhotoActionsView(
                onRetake: retakePhoto,
                onUsePhoto: usePhoto
            )
            .padding(.bottom, max(safeAreaBottom, 16))
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

    private func liveCameraControls(safeArea: EdgeInsets) -> some View {
        VStack {
            cameraTopBar(topInset: safeArea.top)

            Spacer()

            cameraBottomControls(bottomInset: safeArea.bottom)
        }
    }

    private func cameraTopBar(topInset: CGFloat) -> some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColor.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Close Camera")

            Spacer()
        }
        .padding(.top, max(topInset + 8, AppSpacing.cameraCloseTopInset))
        .padding(.horizontal, AppSpacing.cameraCloseHorizontalInset)
    }

    private func cameraBottomControls(bottomInset: CGFloat) -> some View {
        HStack {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.white)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Choose from Gallery")

            Spacer()

            CaptureButton(isEnabled: viewModel.isCaptureReady) {
                AppHaptics.primaryAction()
                Task {
                    await viewModel.capturePhoto()
                }
            }

            Spacer()

            Button {
                AppHaptics.selectionChanged()
                Task {
                    await viewModel.toggleFlash()
                }
            } label: {
                Image(systemName: viewModel.isFlashEnabled ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(viewModel.isFlashEnabled ? AppColor.circleOne : AppColor.white)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .disabled(!viewModel.isFlashAvailable || viewModel.state != .live)
            .accessibilityLabel(viewModel.isFlashEnabled ? "Turn Flash Off" : "Turn Flash On")
        }
        .padding(.horizontal, AppSpacing.cameraBottomControlsHorizontalInset)
        .padding(.bottom, max(bottomInset + 8, AppSpacing.cameraBottomControlsInset))
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

private struct InvertedCutoutShape: Shape {
    let cutoutRect: CGRect
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.addRoundedRect(
            in: cutoutRect,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius),
            style: .continuous
        )
        return path
    }
}
