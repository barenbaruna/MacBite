//
//  CameraControlLabel.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct CameraControlLabel: View {
    let systemImage: String
    let accessibilityLabel: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(AppColor.cameraControlForeground)
            .frame(
                width: AppSize.cameraRoundControl,
                height: AppSize.cameraRoundControl
            )
            .background(AppColor.cameraControlBackground)
            .clipShape(Circle())
            .frame(
                minWidth: AppSize.minimumTouchTarget,
                minHeight: AppSize.minimumTouchTarget
            )
            .accessibilityLabel(accessibilityLabel)
    }
}
