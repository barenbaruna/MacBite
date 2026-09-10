//
//  LoggingOptionCard.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct LoggingOptionCard: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.large) {
                Image(systemName: systemImage)
                    .font(AppTypography.largeTitle)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.headline)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(AppColor.loggingOptionForeground)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.extraExtraLarge)
            .dynamicGlassSurface(cornerRadius: AppCornerRadius.large)
        }
        .buttonStyle(.plain)
    }
}
