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
            Circle()
                .strokeBorder(.white, lineWidth: 4)
                .background(Circle().fill(.white.opacity(0.2)))
                .frame(width: 72, height: 72)
        }
        .buttonStyle(.plain)
    }
}
