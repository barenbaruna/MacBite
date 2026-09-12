//
//  CaptureButton.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

struct CaptureButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.85), lineWidth: 4)
                    .background(Circle().fill(.ultraThinMaterial))
                    .frame(
                        width: AppSize.cameraCaptureOuter,
                        height: AppSize.cameraCaptureOuter
                    )

                Circle()
                    .fill(isEnabled ? AppColor.white : AppColor.buttonDisabled)
                    .frame(
                        width: AppSize.cameraCaptureInner,
                        height: AppSize.cameraCaptureInner
                    )
            }
            .frame(
                width: AppSize.cameraCaptureOuter,
                height: AppSize.cameraCaptureOuter
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel("Take Photo")
        .accessibilityHint(
            isEnabled
                ? "Captures the meal photo"
                : "Complete the light, angle, steadiness, and plate position checks first"
        )
    }
}
