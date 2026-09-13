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
                tint: WidgetColor.calorie
            )
            actionLink(
                title: "Manual",
                systemImage: "pencil",
                action: .manual,
                tint: .primary
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
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, minHeight: WidgetSpacing.minimumTouchTarget)
                .foregroundStyle(tint)
                .background(WidgetColor.actionFill)
                .clipShape(.rect(cornerRadius: WidgetCornerRadius.action))
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
        .accessibilityHint("Membuka pencatatan makanan di MacBite")
    }
}
