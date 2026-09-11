//
//  DashboardView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI
import UIKit

/// Main dashboard view displaying dynamic calorie rings and food logging interactions.
@MainActor
public struct DashboardView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @ObservedObject var viewModel: DashboardViewModel

    @State var screenWidth: CGFloat = 393
    @State var containerCenterY: CGFloat = 426
    @State var presentedFullScreenRoute: AppRoute?
    @State var presentedSheetRoute: AppRoute?

    public init(viewModel: DashboardViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        GeometryReader { safeProxy in
            mainAnimationContainer(safeProxy: safeProxy)
        }
        .onPreferenceChange(RingGeometryPreferenceKey.self) { geometry in
            if geometry.center != .zero { viewModel.ringGeometry = geometry }
        }
        .sheet(isPresented: $viewModel.isShowingProfile) {
            profileSheet
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $presentedFullScreenRoute) { route in
            LoggingDestinationView(
                route: route,
                onDismiss: { presentedFullScreenRoute = nil },
                onUsePhoto: handlePhotoCaptured
            )
        }
        .sheet(item: $presentedSheetRoute) { route in
            LoggingDestinationView(
                route: route,
                onDismiss: { presentedSheetRoute = nil },
                onCalculate: handleManualCalculation
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(AppColor.dark950)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.triggerTapHaptic)
        .sensoryFeedback(.success, trigger: viewModel.triggerSuccessHaptic)
        .alert(
            "Not Food Detected",
            isPresented: Binding(
                get: { viewModel.nonFoodWarningMessage != nil },
                set: { isPresented in
                    if !isPresented { viewModel.dismissNonFoodWarning() }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.dismissNonFoodWarning()
            }
        } message: {
            Text(viewModel.nonFoodWarningMessage ?? "Please try again with a clear photo of your food.")
        }
        .preferredColorScheme(.dark)
    }

    private var isPhaseOrbitingOrDissolving: Bool {
        viewModel.phase == .orbitingAndLoading || viewModel.phase == .dissolvingOrb
    }

    // MARK: - Main Animation Container (Unified Coordinate Space)

    private func mainAnimationContainer(safeProxy: GeometryProxy) -> some View {
        let safeArea = safeProxy.safeAreaInsets
        let fullWidth = safeProxy.size.width + safeArea.leading + safeArea.trailing
        let fullHeight = safeProxy.size.height + safeArea.top + safeArea.bottom

        return ZStack {
            dashboardNavigation(safeArea: safeArea)

            addFoodDimmingLayer

            if viewModel.isShowingAddFood && !isPhaseOrbitingOrDissolving {
                morphingCardOverlay(fullSize: CGSize(width: fullWidth, height: fullHeight), safeArea: safeArea)
                    .zIndex(10)
            }

            if isPhaseOrbitingOrDissolving {
                activeOrbOrbitingLayer
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
        .onChange(of: fullHeight) { _, newH in
            screenWidth = fullWidth
            containerCenterY = newH / 2.0
        }
    }

    private func dashboardNavigation(safeArea: EdgeInsets) -> some View {
        NavigationStack {
            dashboardCanvas(safeArea: safeArea)
                .navigationTitle(viewModel.dailySummary.dateString)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { dashboardToolbar }
        }
    }

    @ViewBuilder
    private var addFoodDimmingLayer: some View {
        if viewModel.isShowingAddFood {
            let shouldDim = viewModel.isCardCompressed && !isPhaseOrbitingOrDissolving
            let dimOpacity = shouldDim ? 0.45 * (1.0 - viewModel.morphProgress) : 0.0

            Color.black
                .opacity(dimOpacity)
                .ignoresSafeArea()
                .transition(.opacity)
        }
    }

    private var activeOrbOrbitingLayer: some View {
        EnergyDropletOrbView(
            scale: viewModel.orbScale,
            blur: viewModel.orbBlur,
            opacity: viewModel.orbGlowOpacity
        )
        .modifier(
            OrbitingProgressModifier(
                progress: viewModel.orbProgress,
                center: viewModel.ringGeometry.center,
                radius: viewModel.ringGeometry.radius
            )
        )
    }

    // MARK: - Morphing Card Overlay (Full Page -> Floating Card -> 28pt Orb)

    private func morphingCardOverlay(fullSize: CGSize, safeArea: EdgeInsets) -> some View {
        let isCardCompressed = viewModel.isCardCompressed
        let maxCardW = min(AppMetrics.modalCardMaxWidth, fullSize.width - AppSpacing.lg)
        let initialW = isCardCompressed ? maxCardW : fullSize.width
        let maxCardH = min(
            AppMetrics.modalCardMaxHeight,
            fullSize.height * AppMetrics.modalCardHeightRatio
        )
        let initialH = isCardCompressed ? maxCardH : fullSize.height
        let initialRadius: CGFloat = isCardCompressed ? AppCornerRadius.modalCard : 0
        let targetDropletSize: CGFloat = AppMetrics.energyDropletSize
        let progress = viewModel.morphProgress

        let currentWidth = initialW - (initialW - targetDropletSize) * progress
        let currentHeight = initialH - (initialH - targetDropletSize) * progress
        let currentCornerRadius = initialRadius - (initialRadius - (targetDropletSize / 2)) * progress
        let shadowRadius: CGFloat = isCardCompressed ? AppMetrics.modalCardShadowRadius * (1.0 - progress) : 0

        return ZStack {
            morphingCardInnerStack(
                width: currentWidth,
                height: currentHeight,
                cornerRadius: currentCornerRadius,
                shadowRadius: shadowRadius,
                safeArea: safeArea
            )
            .offset(x: viewModel.cardOffsetX, y: viewModel.cardOffsetY)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func morphingCardInnerStack(
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat,
        shadowRadius: CGFloat,
        safeArea: EdgeInsets
    ) -> some View {
        let isCardCompressed = viewModel.isCardCompressed
        let progress = viewModel.morphProgress
        let orangeShadowOpacity = isCardCompressed ? (0.24 * (1.0 - progress)) : 0.0

        return ZStack {
            AddFoodReviewCard(
                foodItem: $viewModel.currentFood,
                isCompressed: isCardCompressed,
                flipAngle: viewModel.flipAngle,
                isSaveDisabled: viewModel.phase != .idle,
                safeArea: safeArea,
                onDismiss: dismissReviewCard,
                onSave: triggerSaveAnimation
            )
            .opacity(viewModel.cardContentOpacity)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: AppColor.orange500.opacity(orangeShadowOpacity),
                radius: shadowRadius,
                y: isCardCompressed ? 12 : 0
            )
            .shadow(
                color: Color.black.opacity(0.32 * (1.0 - progress)),
                radius: shadowRadius * 0.8,
                y: isCardCompressed ? 8 : 0
            )
            .rotation3DEffect(.degrees(viewModel.flipAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.28)

            EnergyDropletOrbView(
                scale: viewModel.orbScale,
                blur: viewModel.orbBlur,
                opacity: viewModel.orbGlowOpacity
            )
        }
    }

    // MARK: - Dashboard Canvas

    private func dashboardCanvas(safeArea: EdgeInsets) -> some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: AppSpacing.sm)

                calorieRingSection

                Spacer().frame(height: AppSpacing.md)

                coachInsightSection

                Spacer(minLength: AppSpacing.sm)

                macroGridSection

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .overlay(alignment: .bottomTrailing) {
                floatingActionBar
                    .padding(.trailing, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.md)
            }

            if viewModel.isShowingLoggingOptions {
                LoggingOptionsOverlay(
                    onCameraSelected: showCamera,
                    onManualInputSelected: showManualInput,
                    onDismiss: toggleLoggingOptions
                )
                .transition(loggingOptionsTransition)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var dashboardToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                // Calendar action
            } label: {
                Image(systemName: "calendar")
            }
            .accessibilityLabel("Calendar History")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.isShowingProfile = true
            } label: {
                Image(systemName: "person.crop.circle")
            }
            .accessibilityLabel("Profile and Target Weight")
        }
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel())
}
