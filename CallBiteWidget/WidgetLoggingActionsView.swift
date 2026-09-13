//
//  WidgetLoggingActionsView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

struct WidgetLoggingActionsView: View {
    var body: some View {
        HStack(spacing: WidgetSpacing.small) {
            actionLink(
                title: "Kamera",
                systemImage: "camera.fill",
                action: .camera,
                tint: WidgetColor.cameraActionTint
            )
            actionLink(
                title: "Manual",
                systemImage: "pencil",
                action: .manual,
                tint: WidgetColor.manualActionTint
            )
        }
    }

    private func actionLink(
        title: String,
        systemImage: String,
        action: CallBiteWidgetAction,
        tint: Color
    ) -> some View {
        Link(destination: action.url) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, minHeight: WidgetSpacing.minimumTouchTarget)
                .foregroundStyle(tint)
                .background(WidgetColor.actionBackground)
                .clipShape(RoundedRectangle(cornerRadius: WidgetCornerRadius.action, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: WidgetCornerRadius.action, style: .continuous)
                        .strokeBorder(WidgetColor.borderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
        .accessibilityHint("Membuka pencatatan makanan di MacBite")
    }
}
