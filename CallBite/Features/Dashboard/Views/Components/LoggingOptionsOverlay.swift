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
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            dimmedBackdrop

            VStack(spacing: AppSpacing.large) {
                Spacer()

                Text("Logging Food")
                    .font(AppTypography.title2.weight(.bold))
                    .foregroundStyle(AppColor.white)

                optionCards

                Spacer()

                closeButton
            }
            .padding(.horizontal, AppSpacing.medium)
        }
    }

    private var dimmedBackdrop: some View {
        Color.black.opacity(0.85)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
            .onTapGesture {
                onDismiss()
            }
    }

    private var optionCards: some View {
        HStack(spacing: AppSpacing.medium) {
            LoggingOptionCard(
                title: "Take Photo",
                systemImage: "camera.fill",
                action: onCameraSelected
            )

            LoggingOptionCard(
                title: "Manual Input",
                systemImage: "pencil",
                action: onManualInputSelected
            )
        }
    }

    private var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .tint(.white)
        .accessibilityLabel("Close Logging Options")
        .padding(.bottom, AppSpacing.large)
    }
}
