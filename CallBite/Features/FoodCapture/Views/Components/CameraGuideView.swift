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

            VStack(spacing: .zero) {
                Text("Keep the whole meal visible, use good lighting, and make sure the photo is clear and not blurry.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.cameraGuideForeground)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, AppSpacing.extraExtraLarge)
                    .padding(.top, AppSpacing.cameraGuideTextTop)

                Spacer()

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
                .padding(.bottom, AppSpacing.cameraGuideInset)
            }
            .frame(width: AppSize.cameraGuide, height: AppSize.cameraGuide)
            .background(AppColor.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.cameraGuide,
                    style: .continuous
                )
            )
        }
        .transition(.opacity)
        .accessibilityAddTraits(.isModal)
    }
}
