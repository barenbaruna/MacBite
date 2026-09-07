//
//  SaveFoodAnimationProofView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

// MARK: - Motion Configuration
private enum MotionConfig {
    static let compressDuration: Double = 0.70
    static let readingPause: UInt64 = 450_000_000
    static let morphDuration: Double = 0.62
    static let progressDuration: Double = 0.88
    static let dissolveDuration: Double = 0.50
    static let ringBounceDuration: Double = 0.42

    static let compressFlipSpring: Animation = .smooth(duration: compressDuration)
    static let morphTravelSpring: Animation = .smooth(duration: morphDuration)
    static let progressSpring: Animation = .smooth(duration: progressDuration)
    static let dissolveEase: Animation = .easeOut(duration: dissolveDuration)
    static let ringBounceSpring: Animation = .bouncy(duration: ringBounceDuration)
}

// MARK: - Animation State Machine
private enum SaveAnimationPhase: Equatable {
    case idle, compressingAndFlipping, readingConfirmed
    case morphingAndFlowing, orbitingAndLoading, dissolvingOrb, completed
}

// MARK: - Main View
struct SaveFoodAnimationProofView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: SaveAnimationPhase = .idle
    @State private var isShowingAddFood = true
    @State private var isCardCompressed = false
    @State private var isShowingWeightGoal = false

    // Dynamic Food Data for Testing
    @State private var currentFood: FoodItem = .dimsumMentai
    private let targetDailyCalories: Int = 2400

    // Card & Flow Motion Properties
    @State private var flipAngle = 0.0
    @State private var morphProgress: CGFloat = 0.0
    @State private var cardContentOpacity = 1.0
    @State private var orbGlowOpacity = 0.0
    @State private var orbScale: CGFloat = 1.0
    @State private var orbBlur: CGFloat = 0.0
    @State private var cardOffsetX: CGFloat = 0.0
    @State private var cardOffsetY: CGFloat = 0.0

    // Dynamic Ring Geometry & Dashboard States
    @State private var ringGeometry = RingGeometry()
    @State private var screenWidth: CGFloat = 393
    @State private var containerCenterY: CGFloat = 0.0
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity = 0.0
    @State private var ringProgress: CGFloat = 0.0
    @State private var orbProgress: CGFloat = 0.0
    @State private var ringScale: CGFloat = 1.0
    @State private var totalCaloriesText = "—/—"
    @State private var triggerTapHaptic = false
    @State private var triggerSuccessHaptic = false

    var body: some View {
        GeometryReader { safeProxy in
            mainAnimationContainer(safeProxy: safeProxy)
        }
        .onPreferenceChange(RingGeometryPreferenceKey.self) { geometry in
            if geometry.center != .zero { ringGeometry = geometry }
        }
        .sheet(isPresented: $isShowingWeightGoal) {
            WeightGoalFactory.createView()
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: triggerTapHaptic)
        .sensoryFeedback(.success, trigger: triggerSuccessHaptic)
    }

    private func mainAnimationContainer(safeProxy: GeometryProxy) -> some View {
        let safeArea = safeProxy.safeAreaInsets
        let fullWidth = safeProxy.size.width + safeArea.leading + safeArea.trailing
        let fullHeight = safeProxy.size.height + safeArea.top + safeArea.bottom

        return ZStack {
            dashboardView(safeArea: safeArea)

            if isShowingAddFood {
                Color.black.opacity(
                    isCardCompressed && phase != .orbitingAndLoading && phase != .dissolvingOrb
                    ? 0.42 * (1.0 - morphProgress) : 0.0
                )
                .transition(.opacity)

                if phase != .orbitingAndLoading && phase != .dissolvingOrb {
                    morphingCardOverlay(fullSize: CGSize(width: fullWidth, height: fullHeight))
                        .zIndex(10)
                }
            }

            if phase == .orbitingAndLoading || phase == .dissolvingOrb {
                EnergyDropletOrbView(scale: orbScale, blur: orbBlur, opacity: orbGlowOpacity)
                    .modifier(
                        OrbitingProgressModifier(
                            progress: orbProgress,
                            center: ringGeometry.center,
                            radius: ringGeometry.radius
                        )
                    )
                    .zIndex(20)
            }
        }
        .frame(width: fullWidth, height: fullHeight)
        .coordinateSpace(name: "saveFlowCoordinateSpace")
        .ignoresSafeArea()
        .onAppear {
            screenWidth = fullWidth
            containerCenterY = fullHeight / 2.0
        }
        .onChange(of: safeProxy.size) { _, _ in
            screenWidth = fullWidth
            containerCenterY = fullHeight / 2.0
        }
    }
}

// MARK: - Morphing Card Overlay
private extension SaveFoodAnimationProofView {
    var cardFlipperContent: some View {
        ZStack {
            SavedConfirmationContent(foodItem: currentFood, isSymbolActive: flipAngle >= 90)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipAngle >= 90 ? 1.0 : 0.0)

            AddFoodCardContent(
                foodItem: $currentFood,
                isCompressed: isCardCompressed,
                onDismiss: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowingAddFood = false
                    }
                },
                onSave: { startSmoothSaveAnimation() },
                isSaveDisabled: phase != .idle
            )
            .opacity(flipAngle < 90 ? 1.0 : 0.0)
        }
    }

    func morphingCardOverlay(fullSize: CGSize) -> some View {
        let screenW = fullSize.width > 0 ? fullSize.width : 393
        let screenH = fullSize.height > 0 ? fullSize.height : 852
        let floatingCardW = min(screenW - 32, 360)
        let floatingCardH = min(screenH * 0.84, 680)
        let baseCornerRadius: CGFloat = 32
        let targetDropletSize: CGFloat = 52

        let initialW = isCardCompressed ? floatingCardW : screenW
        let initialH = isCardCompressed ? floatingCardH : screenH
        let initialRadius: CGFloat = isCardCompressed ? baseCornerRadius : 0

        let currentWidth = initialW - (initialW - targetDropletSize) * morphProgress
        let currentHeight = initialH - (initialH - targetDropletSize) * morphProgress
        let currentCornerRadius = initialRadius - (initialRadius - (targetDropletSize / 2)) * morphProgress
        let shadowRadius: CGFloat = isCardCompressed ? 24 * (1.0 - morphProgress) : 0

        return ZStack {
            ZStack {
                cardFlipperContent
                    .opacity(cardContentOpacity)
                    .frame(width: currentWidth, height: currentHeight)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: currentCornerRadius, style: .continuous))
                    .shadow(
                        color: .black.opacity(0.14 * (1.0 - morphProgress)),
                        radius: shadowRadius,
                        y: isCardCompressed ? 10 : 0
                    )
                    .rotation3DEffect(.degrees(flipAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.28)

                EnergyDropletOrbView(scale: orbScale, blur: orbBlur, opacity: orbGlowOpacity)
            }
            .offset(x: cardOffsetX, y: cardOffsetY)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

// MARK: - Dashboard Components
private extension SaveFoodAnimationProofView {
    func dashboardView(safeArea: EdgeInsets) -> some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                DashboardSupportingViews.header {
                    isShowingWeightGoal = true
                }
                .padding(.top, safeArea.top)
                Spacer()
                dashboardCircularRing
                Spacer().frame(height: AppSpacing.sm)
                DashboardSupportingViews.streakBadge
                Spacer()
                DashboardSupportingViews.totalForBulkCard(caloriesText: totalCaloriesText)
                    .padding(.horizontal, AppSpacing.lg)
                Spacer().frame(height: AppSpacing.md)
                dashboardBottomBar
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, safeArea.bottom)
            }
        }
    }

    var dashboardCircularRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 3)
                .frame(width: 140, height: 140)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)

            Circle()
                .stroke(Color(.systemGray4), lineWidth: 28)
                .frame(width: 210, height: 210)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Color(.systemGray), style: StrokeStyle(lineWidth: 28, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 210, height: 210)
        }
        .scaleEffect(ringScale)
        .background(
            GeometryReader { ringProxy in
                let frame = ringProxy.frame(in: .named("saveFlowCoordinateSpace"))
                Color.clear.preference(
                    key: RingGeometryPreferenceKey.self,
                    value: RingGeometry(
                        center: CGPoint(x: frame.midX, y: frame.midY),
                        radius: 105.0
                    )
                )
            }
        )
    }

    var dashboardBottomBar: some View {
        HStack {
            Spacer()
            Button {
                resetAndOpenAddFood()
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(.systemGray))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityLabel("Add Food")
        }
    }
}

// MARK: - Animation Sequence
private extension SaveFoodAnimationProofView {
    func startSmoothSaveAnimation() {
        triggerTapHaptic.toggle()
        if reduceMotion {
            executeReduceMotionFallback()
            return
        }

        phase = .compressingAndFlipping
        withAnimation(MotionConfig.compressFlipSpring) {
            isCardCompressed = true
            flipAngle = 180.0
        } completion: {
            phaseHoldConfirmation()
        }
    }

    func phaseHoldConfirmation() {
        phase = .readingConfirmed
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: MotionConfig.readingPause)
            phaseMorphToLightAndFlow()
        }
    }

    func phaseMorphToLightAndFlow() {
        phase = .morphingAndFlowing
        withAnimation(.easeInOut(duration: 0.22)) {
            cardContentOpacity = 0.0
            orbGlowOpacity = 1.0
            orbScale = 1.0
            orbBlur = 0.0
        }

        let targetOffsetY = ringGeometry.apex.y - containerCenterY
        let targetOffsetX = ringGeometry.apex.x - (screenWidth / 2.0)

        withAnimation(MotionConfig.morphTravelSpring) {
            morphProgress = 1.0
            cardOffsetY = targetOffsetY
            cardOffsetX = targetOffsetX
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(MotionConfig.morphDuration * 1_000_000_000))
            phaseStartOrbitAndFillProgress()
        }
    }

    func phaseStartOrbitAndFillProgress() {
        phase = .orbitingAndLoading
        orbProgress = 0.0

        let calculatedProgress = min(1.0, Double(currentFood.calories) / Double(targetDailyCalories))
        withAnimation(MotionConfig.progressSpring) {
            ringProgress = calculatedProgress
            orbProgress = calculatedProgress
            totalCaloriesText = "\(currentFood.calories) / \(targetDailyCalories.formatted())"
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(MotionConfig.progressDuration * 1_000_000_000))
            phaseDissolveOrb()
        }
    }

    func phaseDissolveOrb() {
        phase = .dissolvingOrb
        triggerSuccessHaptic.toggle()

        rippleScale = 0.5
        rippleOpacity = 0.85
        withAnimation(.easeOut(duration: 0.55)) {
            rippleScale = 1.5
            rippleOpacity = 0.0
        }

        withAnimation(MotionConfig.ringBounceSpring) {
            ringScale = 1.08
        }

        withAnimation(MotionConfig.dissolveEase) {
            orbScale = 0.15
            orbBlur = 10.0
            orbGlowOpacity = 0.0
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 320_000_000)
            withAnimation(.smooth(duration: 0.3)) {
                ringScale = 1.0
            }
            try? await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.easeInOut(duration: 0.25)) {
                isShowingAddFood = false
                phase = .completed
            }
        }
    }

    func executeReduceMotionFallback() {
        let calculatedProgress = min(1.0, Double(currentFood.calories) / Double(targetDailyCalories))
        withAnimation(.easeInOut(duration: 0.35)) {
            isShowingAddFood = false
            ringProgress = calculatedProgress
            totalCaloriesText = "\(currentFood.calories) / \(targetDailyCalories.formatted())"
            triggerSuccessHaptic.toggle()
            phase = .completed
        }
    }

    func resetAndOpenAddFood() {
        isCardCompressed = false
        flipAngle = 0.0
        morphProgress = 0.0
        (orbProgress, cardContentOpacity, orbGlowOpacity) = (0.0, 1.0, 0.0)
        (orbScale, orbBlur, cardOffsetX, cardOffsetY) = (1.0, 0.0, 0.0, 0.0)
        (rippleScale, rippleOpacity, ringScale, ringProgress) = (0.5, 0.0, 1.0, 0.0)
        totalCaloriesText = "—/—"
        phase = .idle
        withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
            isShowingAddFood = true
        }
    }
}

// MARK: - Preview
#Preview {
    SaveFoodAnimationProofView()
}
