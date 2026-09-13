//
//  EnergyDropletOrbView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Luminous energy orb representing nutrition data flowing from the card into the progress ring.
public struct EnergyDropletOrbView: View {
    public let scale: CGFloat
    public let blur: CGFloat
    public let opacity: Double

    public init(scale: CGFloat = 1.0, blur: CGFloat = 0.0, opacity: Double = 1.0) {
        self.scale = scale
        self.blur = blur
        self.opacity = opacity
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(AppColor.ringYellow.opacity(0.40))
                .frame(width: 36, height: 36)
                .blur(radius: 5)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, AppColor.ringYellow, AppColor.ringOrange],
                        center: .center,
                        startRadius: 2,
                        endRadius: 14
                    )
                )
                .frame(width: 28, height: 28)
                .shadow(color: AppColor.ringOrange.opacity(0.75), radius: 4, x: 0, y: 0)

            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
        }
        .scaleEffect(scale)
        .blur(radius: blur)
        .opacity(opacity)
    }
}

#Preview {
    ZStack {
        AppColor.dark950.ignoresSafeArea()
        EnergyDropletOrbView()
    }
    .preferredColorScheme(.dark)
}
