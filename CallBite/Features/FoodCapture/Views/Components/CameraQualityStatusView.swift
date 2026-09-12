//
//  CameraQualityStatusView.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import SwiftUI

struct CameraQualityStatusView: View {
    let checks: CameraQualityChecks

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            statusLabel(
                title: "Light",
                systemImage: "sun.max.fill",
                isPassing: checks.hasAcceptableLighting
            )
            statusLabel(
                title: "Angle",
                systemImage: "gyroscope",
                isPassing: checks.hasAcceptableAngle
            )
            statusLabel(
                title: "Steady",
                systemImage: "hand.raised.fill",
                isPassing: checks.isSteady
            )
        }
        .padding(.horizontal, AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.cameraStatusBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSize.cameraStatusCornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityStatus)
    }

    private func statusLabel(
        title: String,
        systemImage: String,
        isPassing: Bool
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(AppTypography.body)
            .foregroundStyle(
                isPassing
                    ? AppColor.cameraCheckPassed
                    : AppColor.cameraCheckPending
            )
    }

    private var accessibilityStatus: String {
        let lightStatus = checks.hasAcceptableLighting ? "ready" : "adjust"
        let angleStatus = checks.hasAcceptableAngle ? "ready" : "adjust"
        let steadyStatus = checks.isSteady ? "ready" : "adjust"
        return "Light \(lightStatus), angle \(angleStatus), steadiness \(steadyStatus)"
    }
}
