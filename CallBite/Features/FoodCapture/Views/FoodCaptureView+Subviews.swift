//
//  FoodCaptureView+Subviews.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import PhotosUI
import SwiftUI

extension FoodCaptureView {
    func viewfinderLayer(layout: CameraGuidanceLayout) -> some View {
        ZStack {
            AppColor.dark950

            CameraPreview(captureSession: viewModel.captureSession)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)

            if let capturedImage = viewModel.capturedImage {
                capturedPhotoView(image: capturedImage, layout: layout)
            } else {
                liveCameraOverlay(layout: layout)
            }

            firstUseGuide
        }
    }

    private func capturedPhotoView(image: UIImage, layout: CameraGuidanceLayout) -> some View {
        ZStack {
            Color.black.opacity(0.85)

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(
                    width: layout.guideFrame.width,
                    height: layout.guideFrame.height
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppSize.cameraSafeAreaCornerRadius,
                        style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: AppSize.cameraSafeAreaCornerRadius,
                        style: .continuous
                    )
                    .strokeBorder(Color.white, lineWidth: AppSize.cameraSafeAreaStroke)
                )
                .position(
                    x: layout.guideFrame.midX,
                    y: layout.guideFrame.midY
                )
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
                .accessibilityLabel("Captured food photo")
        }
    }

    @ViewBuilder
    private func liveCameraOverlay(layout: CameraGuidanceLayout) -> some View {
        cameraStatus

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
    }

    func guideFrameBlurMask(layout: CameraGuidanceLayout) -> some View {
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
    var firstUseGuide: some View {
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
    var cameraStatus: some View {
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

    var cameraTopBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(AppColor.dark950)
                    .accessibilityHidden(true)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .controlSize(.extraLarge)
            .tint(AppColor.white)
            .accessibilityLabel("Close Camera")

            Spacer()
        }
        .padding(.top, 12)
        .padding(.horizontal, AppSpacing.cameraCloseHorizontalInset)
    }

    var cameraBottomControls: some View {
        HStack {
            galleryPickerButton
            Spacer()
            shutterButton
            Spacer()
            flashButton
        }
        .padding(.horizontal, AppSpacing.cameraBottomControlsHorizontalInset)
        .padding(.bottom, 16)
    }

    private var galleryPickerButton: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Image(systemName: "photo")
                .font(.body.weight(.semibold))
                .foregroundStyle(AppColor.dark950)
                .accessibilityHidden(true)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.extraLarge)
        .tint(AppColor.white)
        .accessibilityLabel("Choose from Gallery")
    }

    private var shutterButton: some View {
        CaptureButton(isEnabled: viewModel.isCaptureReady) {
            AppHaptics.primaryAction()
            Task {
                await viewModel.capturePhoto()
            }
        }
    }

    private var flashButton: some View {
        Button {
            AppHaptics.selectionChanged()
            Task {
                await viewModel.toggleFlash()
            }
        } label: {
            Image(systemName: viewModel.isFlashEnabled ? "bolt.fill" : "bolt.slash.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(viewModel.isFlashEnabled ? AppColor.circleOne : AppColor.dark950)
                .accessibilityHidden(true)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.extraLarge)
        .tint(AppColor.white)
        .disabled(!viewModel.isFlashAvailable || viewModel.state != .live)
        .accessibilityLabel(viewModel.isFlashEnabled ? "Turn Flash Off" : "Turn Flash On")
    }
}

struct InvertedCutoutShape: Shape {
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
