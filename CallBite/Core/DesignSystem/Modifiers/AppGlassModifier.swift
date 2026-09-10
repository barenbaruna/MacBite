//
//  AppGlassModifier.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

struct AppGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }
}

/// Dynamic Apple HIG liquid glass surface that adapts to system appearance
/// without artificial color tinting, cleanly occluding elements underneath.
struct AppDynamicGlassSurface: View {
    var cornerRadius: CGFloat = AppCornerRadius.modalCard

    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)

            Rectangle()
                .fill(.regularMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color(uiColor: .separator).opacity(0.35), lineWidth: 1.0)
        )
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppGlassModifier())
    }

    func dynamicGlassSurface(cornerRadius: CGFloat = AppCornerRadius.modalCard) -> some View {
        background(AppDynamicGlassSurface(cornerRadius: cornerRadius))
    }
}
