//
//  FoodCaptureView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Tampilan kamera untuk menangkap foto makanan
struct FoodCaptureView: View {
    @ObservedObject var viewModel: FoodCaptureViewModel

    var body: some View {
        VStack {
            Spacer()
            Text("Camera Capture Preview")
                .foregroundStyle(.secondary)
            Spacer()
            CaptureButton {
                viewModel.state = .capturing
            }
            .padding(.bottom, 32)
        }
        .background(Color.black)
    }
}
