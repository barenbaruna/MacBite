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
        let food = FoodItem(
            name: "Scanned Food",
            mealType: "1st Meal",
            dateString: viewModel.dailySummary.dateString,
            calories: 475,
            protein: 24,
            carbs: 45,
            fat: 14,
            fiber: 4,
            photoSystemName: "camera.fill"
        )
        navigateToSaveFood(food)
    }

    func handleManualCalculation(name: String, ingredients: [ManualIngredientInput]) {
        presentedSheetRoute = nil
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmed.isEmpty ? "Dimsum Mentai" : trimmed

        let totalGrams = ingredients.compactMap { Int($0.portionGrams) }.reduce(0, +)
        let baseGrams = totalGrams > 0 ? totalGrams : 100
        let ratio = Double(baseGrams) / 100.0

        let food = FoodItem(
            name: displayName,
            mealType: "1st Meal",
            dateString: viewModel.dailySummary.dateString,
            calories: max(50, Int(220.0 * ratio)),
            protein: max(5, Int(15.0 * ratio)),
            carbs: max(5, Int(25.0 * ratio)),
            fat: max(2, Int(8.0 * ratio)),
            fiber: max(1, Int(2.0 * ratio)),
            photoSystemName: "fork.knife"
        )
        navigateToSaveFood(food)
    }

    private func navigateToSaveFood(_ foodItem: FoodItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
                viewModel.resetAndOpenAddFood(with: foodItem)
            }
        }
    }
}
