//
//  FoodCaptureFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI
import UIKit

enum FoodCaptureFactory {
    @MainActor
    static func makeView(
        onDismiss: @escaping () -> Void = {},
        onUsePhoto: @escaping (UIImage) -> Void = { _ in }
    ) -> some View {
        let cameraService = CameraService()
        let motionService = MotionService()
        let guideStore = UserDefaultsCameraGuideStore()
        let viewModel = FoodCaptureViewModel(
            cameraService: cameraService,
            motionService: motionService,
            guideStore: guideStore
        )

        return FoodCaptureView(
            viewModel: viewModel,
            onDismiss: onDismiss,
            onUsePhoto: onUsePhoto
        )
    }
}
