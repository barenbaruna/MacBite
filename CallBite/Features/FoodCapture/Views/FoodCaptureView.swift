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
    @State private var isAnalyzing = false
    @State private var nonFoodDetectedMessage: String?

    let onDismiss: () -> Void
    let onUsePhoto: (UIImage) async -> Bool

    init(
        viewModel: FoodCaptureViewModel,
        onDismiss: @escaping () -> Void,
        onUsePhoto: @escaping (UIImage) async -> Bool
    ) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        self.onUsePhoto = onUsePhoto
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let layout = CameraGuidanceLayout(viewportSize: geometry.size)

                ZStack {
                    AppColor.dark950

                    if let capturedImage = viewModel.capturedImage {
                        Color.black.opacity(0.85)

                        Image(uiImage: capturedImage)
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
                    } else {
                        CameraPreview(captureSession: viewModel.captureSession)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .accessibilityHidden(true)

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

                    firstUseGuide
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .clipped()
                .onAppear {
                    updatePreviewLayout(size: geometry.size, layout: layout)
                }
                .onChange(of: geometry.size) { _, newSize in
                    let updatedLayout = CameraGuidanceLayout(viewportSize: newSize)
                    updatePreviewLayout(size: newSize, layout: updatedLayout)
                }
            }
            .ignoresSafeArea()

            VStack {
                cameraTopBar

                Spacer()

                if viewModel.state != .captured {
                    cameraBottomControls
                }
            }
            .overlay(alignment: .bottom) {
                if viewModel.state == .captured && !isAnalyzing {
                    CapturedPhotoActionsView(
                        onRetake: retakePhoto,
                        onUsePhoto: usePhoto
                    )
                    .padding(.bottom, 16)
                    .zIndex(1)
                }
            }

            if isAnalyzing {
                AnalysisLoadingView(message: "Analyzing your meal…")
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isAnalyzing)
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
        .alert(
            "Food Not Detected",
            isPresented: Binding(
                get: { nonFoodDetectedMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        nonFoodDetectedMessage = nil
                    }
                }
            )
        ) {
            Button("Retake Photo") {
                nonFoodDetectedMessage = nil
                Task {
                    await viewModel.retakePhoto()
                }
            }
            Button("Cancel", role: .cancel) {
                nonFoodDetectedMessage = nil
            }
        } message: {
            Text(nonFoodDetectedMessage ?? "Please retake the photo with your meal clearly visible in the guide frame.")
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

    private var cameraTopBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColor.dark950)
                    .accessibilityHidden(true)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(AppColor.white)
            .frame(
                width: AppSize.cameraRoundControl,
                height: AppSize.cameraRoundControl
            )
            .accessibilityLabel("Close Camera")

            Spacer()
        }
        .padding(.top, 12)
        .padding(.horizontal, AppSpacing.cameraCloseHorizontalInset)
    }

    private var cameraBottomControls: some View {
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.dark950)
                .accessibilityHidden(true)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .tint(AppColor.white)
        .frame(
            width: AppSize.cameraSecondaryControl,
            height: AppSize.cameraSecondaryControl
        )
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(viewModel.isFlashEnabled ? AppColor.circleOne : AppColor.dark950)
                .accessibilityHidden(true)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .tint(AppColor.white)
        .frame(
            width: AppSize.cameraSecondaryControl,
            height: AppSize.cameraSecondaryControl
        )
        .disabled(!viewModel.isFlashAvailable || viewModel.state != .live)
        .accessibilityLabel(viewModel.isFlashEnabled ? "Turn Flash Off" : "Turn Flash On")
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
        guard let image = viewModel.capturedImage, !isAnalyzing else { return }
        AppHaptics.primaryAction()
        withAnimation(.easeInOut(duration: 0.2)) {
            isAnalyzing = true
        }
        Task {
            let success = await onUsePhoto(image)
            if !success {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAnalyzing = false
                }
                AppHaptics.warning()
                nonFoodDetectedMessage = "We couldn't detect food in this photo. " +
                    "Please retake the photo with your meal clearly visible in the guide frame."
            }
        }
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
