//
//  CapturedPhotoActionsView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct CapturedPhotoActionsView: View {
    let onRetake: () -> Void
    let onUsePhoto: () -> Void

    var body: some View {
        HStack(spacing: .zero) {
            actionButton(
                title: "Retake",
                alignment: .leading,
                action: onRetake
            )
            actionButton(
                title: "Use Photo",
                alignment: .trailing,
                action: onUsePhoto
            )
        }
        .padding(.horizontal, AppSpacing.extraLarge)
        .frame(maxWidth: .infinity)
        .frame(height: AppSize.cameraActionBarHeight)
        .background(AppColor.cameraActionBar)
    }

    private func actionButton(
        title: String,
        alignment: Alignment,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.white)
                .fixedSize()
        }
        .buttonStyle(.plain)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: alignment
        )
        .contentShape(Rectangle())
    }
}
