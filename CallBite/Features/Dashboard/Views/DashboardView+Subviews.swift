//
//  DashboardView+Subviews.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 10/09/26.
//

import SwiftUI
import UIKit

// MARK: - DashboardView Subviews & Actions

extension DashboardView {
    var isPhaseOrbitingOrDissolving: Bool {
        viewModel.phase == .orbitingAndLoading || viewModel.phase == .dissolvingOrb
    }

    var profileSheet: some View {
        ProfileFactory.makeView(
            onSave: { updatedProfile in
                UserProfileStore.shared.updateProfile(updatedProfile)

                // Recalculate and update dashboard targets in real-time
                if let newGoal = UserProfileStore.shared.nutritionGoal {
                    viewModel.updateNutritionTargets(newGoal)
                }
            }
        )
    }

    var calorieRingSection: some View {
        CalorieProgressView(
            consumedCalories: viewModel.dailySummary.consumedCalories,
            targetCalories: viewModel.dailySummary.targetCalories,
            ringProgress: viewModel.ringProgress,
            ringScale: viewModel.ringScale,
            rippleScale: viewModel.rippleScale,
            rippleOpacity: viewModel.rippleOpacity,
            isDropletActive: false,
            dropletScale: viewModel.orbScale,
            dropletOpacity: viewModel.orbGlowOpacity
        )
    }

    var coachInsightSection: some View {
        Text(viewModel.coachInsight)
            .font(AppTypography.subheadline)
            .foregroundStyle(Color(uiColor: .label))
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
    }

    var macroGridSection: some View {
        MacroSummaryGridView(
            consumedCalories: viewModel.dailySummary.consumedCalories,
            targetCalories: viewModel.dailySummary.targetCalories,
            carbsGrams: viewModel.dailySummary.totalCarbs,
            targetCarbsGrams: viewModel.dailySummary.targetCarbs,
            proteinGrams: viewModel.dailySummary.totalProtein,
            targetProteinGrams: viewModel.dailySummary.targetProtein,
            fatGrams: viewModel.dailySummary.totalFat,
            targetFatGrams: viewModel.dailySummary.targetFat,
            fiberGrams: viewModel.dailySummary.totalFiber,
            targetFiberGrams: viewModel.dailySummary.targetFiber
        )
    }

    var foodHistorySection: some View {
        DashboardFoodHistorySection(
            foods: viewModel.foodsForSelectedDate,
            onFoodTap: { food in
                selectedHistoryFood = food
            }
        )
    }

    var floatingActionBar: some View {
        Button(action: toggleLoggingOptions) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .tint(.white)
        .accessibilityLabel("Log Food")
    }

    var loggingOptionsTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom))
    }

    var loggingAnimation: Animation {
        reduceMotion ? AppAnimation.reducedMotion : AppAnimation.smooth
    }

    func toggleLoggingOptions() {
        AppHaptics.primaryAction()
        withAnimation(loggingAnimation) {
            viewModel.toggleLoggingOptions()
        }
    }

    func showCamera() {
        prepareForLoggingPresentation()
        presentedFullScreenRoute = .foodCapture
    }

    func showManualInput() {
        prepareForLoggingPresentation()
        presentedSheetRoute = .manualLogging
    }

    func showCalendar() {
        AppHaptics.selectionChanged()
        viewModel.hideLoggingOptions()
        isShowingCalendar = true
    }

    func showProfile() {
        AppHaptics.selectionChanged()
        viewModel.hideLoggingOptions()
        viewModel.isShowingProfile = true
    }

    func handleCalendarSelection(_ date: Date) {
        guard viewModel.selectDate(date) else { return }
        isShowingCalendar = false
    }

    func returnToToday() {
        AppHaptics.selectionChanged()
        viewModel.returnToToday()
    }

    func prepareForLoggingPresentation() {
        AppHaptics.selectionChanged()
        viewModel.hideLoggingOptions()
    }

    func dismissReviewCard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.isShowingAddFood = false
        }
    }

    func triggerSaveAnimation() {
        viewModel.startSaveAnimation(
            reduceMotion: reduceMotion,
            screenWidth: screenWidth,
            containerCenterY: containerCenterY
        )
    }

    // MARK: - Save Food Navigation

    func handlePhotoCaptured(_ image: UIImage) async -> Bool {
        let success = await viewModel.analyzeCapturedPhoto(image)
        if success {
            presentedFullScreenRoute = nil
        } else {
            viewModel.dismissNonFoodWarning()
        }
        return success
    }

    func handleManualCalculation(name: String, ingredients: [ManualIngredientInput]) {
        presentedSheetRoute = nil
        Task {
            await viewModel.calculateManualNutrition(name: name, ingredients: ingredients)
        }
    }

    // MARK: - Morphing Card Overlay (Full Page -> Floating Card -> 28pt Orb)

    func morphingCardOverlay(fullSize: CGSize, safeArea: EdgeInsets) -> some View {
        let isCardCompressed = viewModel.isCardCompressed
        let topGap: CGFloat = max(safeArea.top + 10, 68)

        let initialW = fullSize.width
        let initialH = isCardCompressed ? (fullSize.height - topGap) : fullSize.height
        let baseOffsetY: CGFloat = isCardCompressed ? (topGap / 2.0) : 0
        let initialRadius: CGFloat = isCardCompressed ? AppCornerRadius.modalCard : 0

        let targetDropletSize: CGFloat = AppMetrics.energyDropletSize
        let progress = viewModel.morphProgress

        let currentWidth = initialW - (initialW - targetDropletSize) * progress
        let currentHeight = initialH - (initialH - targetDropletSize) * progress
        let currentCornerRadius = initialRadius - (initialRadius - (targetDropletSize / 2)) * progress
        let currentOffsetY = baseOffsetY * (1.0 - progress) + viewModel.cardOffsetY
        let shadowRadius: CGFloat = isCardCompressed ? AppMetrics.modalCardShadowRadius * (1.0 - progress) : 0

        return ZStack {
            morphingCardInnerStack(
                width: currentWidth,
                height: currentHeight,
                cornerRadius: currentCornerRadius,
                shadowRadius: shadowRadius,
                safeArea: safeArea
            )
            .offset(x: viewModel.cardOffsetX, y: currentOffsetY)
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
}
