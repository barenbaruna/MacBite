//
//  FoodCaptureView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import PhotosUI
import SwiftUI

struct FoodCaptureView: View {
    @ObservedObject var viewModel: FoodCaptureViewModel
    @State var selectedPhoto: PhotosPickerItem?
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
            cameraPreviewSection
                .ignoresSafeArea()

            cameraControlsSection

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
            handleSelectedPhoto(newPhoto)
        }
        .alert("Unable to Take Photo", isPresented: cameraErrorBinding) {
            Button("OK", role: .cancel) { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
        .alert("Food Not Detected", isPresented: nonFoodBinding) {
            Button("Retake Photo") {
                nonFoodDetectedMessage = nil
                Task { await viewModel.retakePhoto() }
            }
            Button("Cancel", role: .cancel) {
                nonFoodDetectedMessage = nil
            }
        } message: {
            Text(nonFoodDetectedMessage ?? "Please retake the photo with your meal clearly visible in the guide frame.")
        }
    }

    private var cameraPreviewSection: some View {
        GeometryReader { geometry in
            let layout = CameraGuidanceLayout(viewportSize: geometry.size)
            viewfinderLayer(layout: layout)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .onAppear {
                    updatePreviewLayout(size: geometry.size, layout: layout)
                }
                .onChange(of: geometry.size) { _, newSize in
                    let updatedLayout = CameraGuidanceLayout(viewportSize: newSize)
                    updatePreviewLayout(size: newSize, layout: updatedLayout)
                }
        }
    }

    private var cameraControlsSection: some View {
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
    }

    private var cameraErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }

    private var nonFoodBinding: Binding<Bool> {
        Binding(
            get: { nonFoodDetectedMessage != nil },
            set: { if !$0 { nonFoodDetectedMessage = nil } }
        )
    }

    private func handleSelectedPhoto(_ newPhoto: PhotosPickerItem?) {
        guard let newPhoto else { return }
        Task {
            if let data = try? await newPhoto.loadTransferable(type: Data.self) {
                viewModel.selectPhoto(data: data)
            }
            selectedPhoto = nil
        }
    }

    private func updatePreviewLayout(size: CGSize, layout: CameraGuidanceLayout) {
        viewModel.updatePreviewLayout(viewportSize: size, guideFrame: layout.guideFrame)
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
