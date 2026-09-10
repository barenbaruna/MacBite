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
            Button(action: onRetake) {
                Text("Retake")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.white)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .leading
                    )
            }
            .buttonStyle(.plain)

            Button(action: onUsePhoto) {
                Text("Use Photo")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.white)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .trailing
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.extraLarge)
        .frame(maxWidth: .infinity)
        .frame(height: AppSize.cameraActionBarHeight)
        .background(AppColor.cameraActionBar)
    }
}
