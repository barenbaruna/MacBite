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
            Color(AppColor.dark950)
                .ignoresSafeArea()

            VStack(spacing: 15) {
                logoPlaceholder

                VStack(spacing: 5) {
                    Text(appName)
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(.primary)
                    Text(tagline)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
        }
        .environment(\.colorScheme, .dark)
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
            .fill(AppColor.orange500)
            .frame(width: 148, height: 148)
            .accessibilityLabel("MacBite Logo")
    }
}

#Preview {
    SplashScreenView(
        appName: "MacBite",
        tagline: "Your Macros, In a Snap"
    )
}
