//
//  AnalysisLoadingView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import SwiftUI

/// Full-screen loading view displayed while AI analyzes food photos or estimates
/// manual nutrition input. Uses the app's design system tokens consistently.
///
/// Animation cycle (inspired by SwiftUI-Animations CircleLoader):
/// 1. Spring snap to start angle
/// 2. Sweep: rotate arc ~2 full turns
/// 3. Expand: grow arc from 0.325 to 0.925
/// 4. Collapse: reset and restart cycle
struct AnalysisLoadingView: View {

    // MARK: - Properties

    let message: String

    /// Gradient for the static background track ring.
    private let trackGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.04)
        ]),
        startPoint: .leading,
        endPoint: .bottomLeading
    )

    /// Gradient for the animated foreground arc — uses the app's orange accent.
    private let arcGradient = LinearGradient(
        gradient: Gradient(colors: [
            AppColor.calorie,
            AppColor.calorie.opacity(0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .trailing
    )

    private let trackerRotation: Double = 2
    private let animationDuration: Double = 0.75

    @State private var circleStart: CGFloat = 0.17
    @State private var circleEnd: CGFloat = 0.325
    @State private var rotationDegree: Angle = .degrees(0)

    // MARK: - Views

    var body: some View {
        ZStack {
            AppColor.dark950
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.extraLarge) {
                loaderRing
                    .frame(width: 120, height: 120)

                VStack(spacing: AppSpacing.small) {
                    Text(message)
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("This may take a few seconds")
                        .font(AppTypography.footnote)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
        }
        .onAppear {
            animateLoader()
            Timer.scheduledTimer(
                withTimeInterval: trackerRotation * animationDuration + animationDuration,
                repeats: true
            ) { _ in
                animateLoader()
            }
        }
    }

    private var loaderRing: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 12))
                .fill(trackGradient)

            Circle()
                .trim(from: circleStart, to: circleEnd)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .fill(arcGradient)
                .rotationEffect(rotationDegree)
        }
    }

    // MARK: - Animation

    private func getRotationAngle() -> Angle {
        .degrees(360 * trackerRotation) + .degrees(120)
    }

    private func animateLoader() {
        withAnimation(.spring(response: animationDuration * 2)) {
            rotationDegree = .degrees(-57.5)
        }

        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            withAnimation(.easeInOut(duration: trackerRotation * animationDuration)) {
                rotationDegree += getRotationAngle()
            }
        }

        Timer.scheduledTimer(withTimeInterval: animationDuration * 1.25, repeats: false) { _ in
            withAnimation(.easeOut(duration: (trackerRotation * animationDuration) / 2.25)) {
                circleEnd = 0.925
            }
        }

        Timer.scheduledTimer(withTimeInterval: trackerRotation * animationDuration, repeats: false) { _ in
            rotationDegree = .degrees(47.5)
            withAnimation(.easeOut(duration: animationDuration)) {
                circleEnd = 0.325
            }
        }
    }
}

#Preview {
    AnalysisLoadingView(message: "Analyzing your meal…")
}
