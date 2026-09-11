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
        DashboardFoodHistorySection(foods: viewModel.foodsForSelectedDate)
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

    func handlePhotoCaptured(_ image: UIImage) {
        presentedFullScreenRoute = nil
        Task { @MainActor in
            
            let imageData = image.jpegData(compressionQuality: 0.82) ?? Data()
            let currentMealType = FoodItem.currentMealType()
            var food = FoodItem(
                name: "Scanned Food",
                mealType: currentMealType,
                dateString: viewModel.dailySummary.dateString,
                calories: 475,
                protein: 24,
                carbs: 45,
                fat: 14,
                fiber: 4,
                photoSystemName: "camera.fill",
                photoData: imageData
            )
            food.mealType = currentMealType
            food.dateString = viewModel.dailySummary.dateString
            navigateToSaveFood(food)
        }
    }

    func handleManualCalculation(name: String, ingredients: [ManualIngredientInput]) {
        presentedSheetRoute = nil
        Task { @MainActor in
            let descriptors = ingredients.map {
                IngredientDescriptor(
                    name: $0.ingredient,
                    portionGrams: Double($0.portionGrams) ?? 0.0,
                    cookingMethod: $0.cookingMethod.isEmpty ? nil : $0.cookingMethod
                )
            }
            let currentMealType = FoodItem.currentMealType()
            var food = FoodItem(
                name: name.isEmpty ? "Healthy Meal" : name,
                mealType: currentMealType,
                dateString: viewModel.dailySummary.dateString,
                calories: 450,
                protein: 25,
                carbs: 40,
                fat: 12,
                fiber: 4,
                photoSystemName: "fork.knife"
            )
            food.mealType = currentMealType
            food.dateString = viewModel.dailySummary.dateString
            navigateToSaveFood(food)
        }
    }

    private func navigateToSaveFood(_ foodItem: FoodItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
                viewModel.resetAndOpenAddFood(with: foodItem)
            }
        }
    }
}
