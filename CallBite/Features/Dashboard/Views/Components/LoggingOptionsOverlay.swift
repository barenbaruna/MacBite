//
//  LoggingOptionsOverlay.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct LoggingOptionsOverlay: View {
    let onCameraSelected: () -> Void
    let onManualInputSelected: () -> Void

    var body: some View {
        ZStack {
            AppColor.dark950.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.large) {
                Spacer(minLength: AppSpacing.extraExtraLarge)

                Text("Logging Food")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColor.white)

                optionCards

                Spacer()
                    .frame(height: AppSpacing.loggingOptionsBottomClearance)
            }
            .padding(.horizontal, AppSpacing.medium)
        }
    }

    private var optionCards: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppSpacing.small) {
                cameraCard
                manualInputCard
            }

            VStack(spacing: AppSpacing.small) {
                cameraCard
                manualInputCard
            }
        }
    }

    private var cameraCard: some View {
        LoggingOptionCard(
            title: "Take Photo",
            systemImage: "camera.fill",
            action: onCameraSelected
        )
    }

    private var manualInputCard: some View {
        LoggingOptionCard(
            title: "Input Manual",
            systemImage: "pencil",
            action: onManualInputSelected
        )
    }
}
