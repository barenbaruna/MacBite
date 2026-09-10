//
//  CameraControlLabel.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct CameraControlLabel: View {
    let systemImage: String
    let accessibilityLabel: String

    var body: some View {
        Image(systemName: systemImage)
            .font(AppTypography.body)
            .accessibilityLabel(accessibilityLabel)
    }
}
