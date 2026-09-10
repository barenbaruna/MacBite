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
                Spacer()

                Image(systemName: systemImage)
                    .font(.system(size: 38, weight: .regular))
                    .foregroundStyle(AppColor.white)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.white)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 190)
            .background(Color(hex: 0x242426))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.extraLarge, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
