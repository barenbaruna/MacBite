//
//  CameraGuidanceLayout.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import CoreGraphics

struct CameraGuidanceLayout {
    let guideFrame: CGRect
    let instructionFrame: CGRect
    let statusFrame: CGRect

    init(viewportSize: CGSize) {
        let guideSize = min(
            AppSize.cameraSafeArea,
            viewportSize.width - AppSpacing.cameraSafeAreaHorizontalInset * 2,
            viewportSize.height * AppMetrics.cameraSafeAreaHeightRatio
        )
        let instructionWidth = min(
            AppSize.cameraInstructionWidth,
            viewportSize.width - AppSpacing.extraLarge * 2
        )
        let statusWidth = min(
            AppSize.cameraStatusWidth,
            viewportSize.width - AppSpacing.extraExtraLarge * 2
        )
        let controlsTop = viewportSize.height
            - AppSpacing.cameraBottomControlsInset
            - AppSize.cameraCaptureOuter
        let contentBelowGuide = AppSpacing.cameraGuideToInstruction
            + AppSize.cameraInstructionHeight
            + AppSpacing.cameraInstructionToStatus
            + AppSize.cameraStatusHeight
            + AppSpacing.cameraStatusToControls
        let maximumGuideTop = controlsTop - contentBelowGuide - guideSize
        let minimumGuideTop = AppSpacing.cameraTopControl
            + AppSize.cameraRoundControl
            + AppSpacing.medium
        let preferredGuideTop = viewportSize.height * AppMetrics.cameraSafeAreaTopRatio
        let guideTop = max(minimumGuideTop, min(preferredGuideTop, maximumGuideTop))

        guideFrame = CGRect(
            x: (viewportSize.width - guideSize) / 2,
            y: guideTop,
            width: guideSize,
            height: guideSize
        )
        instructionFrame = CGRect(
            x: (viewportSize.width - instructionWidth) / 2,
            y: guideFrame.maxY + AppSpacing.cameraGuideToInstruction,
            width: instructionWidth,
            height: AppSize.cameraInstructionHeight
        )
        statusFrame = CGRect(
            x: (viewportSize.width - statusWidth) / 2,
            y: instructionFrame.maxY + AppSpacing.cameraInstructionToStatus,
            width: statusWidth,
            height: AppSize.cameraStatusHeight
        )
    }
}
