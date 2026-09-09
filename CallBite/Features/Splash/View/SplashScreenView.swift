//
//  SplashScreenView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import SwiftUI

struct SplashScreenView: View {
    let appName: String
    let tagline: String
    let onFinish: () -> Void

    init(
        appName: String = "MacBite",
        tagline: String = "Your Macros, In a Snap",
        onFinish: @escaping () -> Void = {}
    ) {
        self.appName = appName
        self.tagline = tagline
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                logoPlaceholder

                VStack(spacing: AppSpacing.xxs) {
                    Text(appName)
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(.primary)
                    Text(tagline)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onFinish()
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            onFinish()
        }
        .preferredColorScheme(.dark)
    }
    
    private var logoPlaceholder: some View {
        Circle()
            .fill(AppColor.primary500)
            .frame(width: 150, height: 150)
            .accessibilityLabel("CallBite Logo")
    }
}

#Preview {
    SplashScreenView(
        appName: "MacBite",
        tagline: "Your Macros, In a Snap"
    )
}
