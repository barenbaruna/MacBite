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
    @State var isShowingCalendar = false
    @State var selectedHistoryFood: FoodItem?
    @Binding var requestedLoggingRoute: AppRoute?

    public init(viewModel: DashboardViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._requestedLoggingRoute = .constant(nil)
    }

    init(viewModel: DashboardViewModel, requestedLoggingRoute: Binding<AppRoute?>) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._requestedLoggingRoute = requestedLoggingRoute
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
        .sheet(isPresented: $isShowingCalendar) {
            CalorieCalendarFactory.makeView(
                summaries: viewModel.calendarSummaries,
                selectedDate: viewModel.selectedDate,
                today: viewModel.todayDate,
                onDismiss: { isShowingCalendar = false },
                onSelect: handleCalendarSelection
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColor.activityCardNormal)
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
        .onAppear(perform: presentRequestedLoggingRoute)
        .onChange(of: requestedLoggingRoute) { _, _ in
            presentRequestedLoggingRoute()
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Main Animation Container (Unified Coordinate Space)

    private func mainAnimationContainer(safeProxy: GeometryProxy) -> some View {
        let safeArea = safeProxy.safeAreaInsets
        let fullWidth = safeProxy.size.width + safeArea.leading + safeArea.trailing
        let fullHeight = safeProxy.size.height + safeArea.top + safeArea.bottom

        #if DEBUG
        print(
            "[DashboardView] render on \(ObjectIdentifier(viewModel)):",
            "isShowingAddFood=\(viewModel.isShowingAddFood)",
            "phase=\(viewModel.phase)",
            "isPhaseOrbitingOrDissolving=\(isPhaseOrbitingOrDissolving)",
            "presentedSheetRoute=\(String(describing: presentedSheetRoute))"
        )
        #endif

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

            if viewModel.isAnalyzing {
                AnalysisLoadingView(message: viewModel.analysisMessage)
                    .transition(.opacity)
                    .zIndex(30)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isAnalyzing)
        .frame(width: fullWidth, height: fullHeight)
        .coordinateSpace(name: "saveFlowCoordinateSpace")
        .ignoresSafeArea(.container)
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
                .toolbar {
                    DashboardToolbarContent(
                        isShowingToday: viewModel.isShowingToday,
                        onReturnToToday: returnToToday,
                        onCalendarSelected: showCalendar,
                        onProfileSelected: showProfile
                    )
                }
                .navigationDestination(item: $selectedHistoryFood) { food in
                    FoodDetailView(
                        foodItem: food,
                        onSave: { updated in
                            viewModel.updateFood(updated)
                        }
                    )
                }
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

    // MARK: - Dashboard Canvas

    private func dashboardCanvas(safeArea: EdgeInsets) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            ScrollView { dashboardScrollContent }
            .scrollIndicators(.hidden)

            floatingActionBar
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, max(AppSpacing.medium, safeArea.bottom))

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

    private var dashboardScrollContent: some View {
        LazyVStack(spacing: 0) {
            calorieRingSection

            Spacer().frame(height: AppSpacing.medium)

            coachInsightSection

            Spacer().frame(height: AppSpacing.regular)

            macroGridSection

            if !viewModel.foodsForSelectedDate.isEmpty {
                foodHistorySection
                    .padding(.top, AppSpacing.dashboardFoodSectionTopSpacing)
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.regular)
        .padding(.bottom, AppSpacing.loggingOptionsBottomClearance)
    }

}

#Preview {
    DashboardView(viewModel: DashboardViewModel())
}
