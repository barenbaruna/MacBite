//
//  FoodCaptureContainerView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import SwiftUI
import UIKit

@MainActor
struct FoodCaptureContainerView: View {
    @StateObject private var viewModel: FoodCaptureViewModel
    private let onDismiss: () -> Void
    private let onUsePhoto: (UIImage) async -> Bool

    init(
        viewModel: @autoclosure @escaping @MainActor () -> FoodCaptureViewModel,
        onDismiss: @escaping () -> Void = {},
        onUsePhoto: @escaping (UIImage) async -> Bool = { _ in true }
    ) {
        self.onDismiss = onDismiss
        self.onUsePhoto = onUsePhoto
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    init(
        onDismiss: @escaping () -> Void = {},
        onUsePhoto: @escaping (UIImage) async -> Bool = { _ in true }
    ) {
        self.init(
            viewModel: FoodCaptureViewModel(
                cameraService: CameraService(),
                motionService: MotionService(),
                guideStore: UserDefaultsCameraGuideStore()
            ),
            onDismiss: onDismiss,
            onUsePhoto: onUsePhoto
        )
    }

    var body: some View {
        FoodCaptureView(
            viewModel: viewModel,
            onDismiss: onDismiss,
            onUsePhoto: onUsePhoto
        )
    }
}
