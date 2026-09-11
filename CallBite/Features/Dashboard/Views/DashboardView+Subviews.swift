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
    var profileSheet: some View {
        ProfileView(
            initialProfile: UserHealthProfile(
                age: 22,
                biologicalSex: .male,
                weightKg: 56.0,
                heightCm: 162.0
            ),
            onSave: { _ in
                // Save updated profile
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
        Text(viewModel.dailySummary.coachInsight)
            .font(AppTypography.subheadline)
            .foregroundStyle(Color(uiColor: .label))
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppSpacing.sm)
    }

    var macroGridSection: some View {
        MacroSummaryGridView(
            consumedCalories: viewModel.dailySummary.consumedCalories,
            targetCalories: viewModel.dailySummary.targetCalories,
            carbsGrams: viewModel.dailySummary.totalCarbs,
            proteinGrams: viewModel.dailySummary.totalProtein,
            fatGrams: viewModel.dailySummary.totalFat,
            fiberGrams: viewModel.dailySummary.totalFiber
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

    func handlePhotoCaptured(_ image: UIImage) {
        presentedFullScreenRoute = nil
        Task {
            await viewModel.analyzeCapturedPhoto(image)
        }
    }

    func handleManualCalculation(name: String, ingredients: [ManualIngredientInput]) {
        presentedSheetRoute = nil
        Task {
            await viewModel.calculateManualNutrition(name: name, ingredients: ingredients)
        }
    }
}
