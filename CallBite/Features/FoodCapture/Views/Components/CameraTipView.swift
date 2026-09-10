//
//  CameraTipView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct CameraTipView: View {
    var body: some View {
        VStack(spacing: .zero) {
            Text("Tips")
                .font(AppTypography.caption2)
                .foregroundStyle(AppColor.white)
                .frame(
                    width: AppSize.cameraTipHeaderWidth,
                    height: AppSize.cameraTipHeaderHeight
                )
                .background(AppColor.cameraTipHeaderBackground)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColor.white, lineWidth: AppSize.cameraControlStroke)
                }
                .zIndex(1)

            Text("Keep the item clearly visible in the frame.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.white)
                .frame(
                    width: AppSize.cameraTipWidth,
                    height: AppSize.cameraTipBodyHeight
                )
                .background(AppColor.cameraTipBackground)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColor.white, lineWidth: AppSize.cameraControlStroke)
                }
                .padding(.top, -AppSpacing.small)
        }
        .accessibilityElement(children: .combine)
    }
}
