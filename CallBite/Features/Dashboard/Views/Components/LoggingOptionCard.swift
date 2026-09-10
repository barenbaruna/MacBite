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
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.headline)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .foregroundStyle(AppColor.white)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.roundedRectangle(radius: AppCornerRadius.extraLarge))
    }
}
