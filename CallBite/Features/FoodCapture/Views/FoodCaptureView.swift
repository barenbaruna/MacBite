//
//  FoodCaptureView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import PhotosUI
import SwiftUI

/// Full-screen camera flow for capturing or importing a food photo.
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
        AppColor.dark950
            .ignoresSafeArea()
            .overlay {
                cameraContent
            }
            .overlay(alignment: .bottom) {
                if viewModel.state == .captured {
                    CapturedPhotoActionsView(
                        onRetake: retakePhoto,
                        onUsePhoto: usePhoto
                    )
                }
            }
            .overlay {
                ZStack {
                    if viewModel.state != .captured {
                        liveCameraControls
                    }

                    if viewModel.isGuidePresented {
                        CameraGuideView {
                            viewModel.dismissGuide()
                            Task {
                                await viewModel.prepareCamera()
                            }
                        }
                    }
                }
            }
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
            HStack {
                cameraControlButton(
                    systemImage: "xmark",
                    accessibilityLabel: "Close Camera",
                    action: onDismiss
                )
                Spacer()
            }
            .padding(.top, AppSpacing.cameraTopControl)
            .padding(.horizontal, AppSpacing.extraExtraLarge)

            Spacer()

            if viewModel.state == .live {
                CameraTipView()
            }

            HStack {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    CameraControlLabel(
                        systemImage: "photo",
                        accessibilityLabel: "Choose from Gallery"
                    )
                }

                Spacer()

                CaptureButton {
                    AppHaptics.primaryAction()
                    Task {
                        await viewModel.capturePhoto()
                    }
                }
                .disabled(viewModel.state != .live)

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
            .padding(.horizontal, AppSpacing.extraExtraLarge)
            .padding(.bottom, AppSpacing.extraLarge)
        }
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
