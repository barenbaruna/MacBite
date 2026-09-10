//
//  CaptureButton.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Tombol shutter kamera
struct CaptureButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColor.gray200)

                Circle()
                    .fill(AppColor.white)
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
        .accessibilityLabel("Take Photo")
    }
}
