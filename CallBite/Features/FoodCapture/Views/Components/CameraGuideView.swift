//
//  CameraGuideView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct CameraGuideView: View {
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            AppColor.dark950.opacity(0.72)
            guideCard
        }
        .transition(.opacity)
        .accessibilityAddTraits(.isModal)
    }

    private var guideCard: some View {
        VStack(spacing: .zero) {
            guideContent
            Spacer(minLength: AppSpacing.cameraGuideTextButtonGap)
            confirmButton
        }
        .padding(.bottom, AppSpacing.cameraGuideInset)
        .frame(width: AppSize.cameraGuide, height: AppSize.cameraGuide)
        .background(AppColor.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.cameraGuide,
                style: .continuous
            )
        )
    }

    private var guideContent: some View {
        VStack(spacing: AppSpacing.cameraGuideIconTextSpacing) {
            Image(systemName: "camera.fill")
                .font(.system(size: AppSize.cameraGuideIcon, weight: .semibold))
                .foregroundStyle(AppColor.cameraControlForeground)
                .accessibilityHidden(true)

            Text("Keep the whole meal visible, use good lighting, and make sure the photo is clear and not blurry.")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.cameraGuideForeground)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                .padding(.horizontal, AppSpacing.extraExtraLarge)
        }
        .padding(.top, AppSpacing.cameraGuideContentTopInset)
        .frame(maxWidth: .infinity)
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text("Got It")
                .font(AppTypography.button)
                .foregroundStyle(AppColor.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppSize.cameraGuideButtonHeight)
                .background(AppColor.cameraGuideButtonBackground)
                .clipShape(.capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.cameraGuideInset)
    }
}
