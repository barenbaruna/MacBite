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

extension View {
    func appCardStyle() -> some View {
        modifier(AppGlassModifier())
    }
}
