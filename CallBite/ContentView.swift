//
//  ContentView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var screenState: AppScreenState = {
        if ProcessInfo.processInfo.arguments.contains("-testProfile") {
            return .testProfile
        } else if ProcessInfo.processInfo.arguments.contains("-testEditSheet") {
            return .testEditSheet
        } else if ProcessInfo.processInfo.arguments.contains("-testFoodCardFront") {
            return .testFoodCardFront
        } else if ProcessInfo.processInfo.arguments.contains("-testFoodCard") {
            return .testFoodCard
        } else if ProcessInfo.processInfo.arguments.contains("-testDashboardExpanded") {
            return .testDashboardExpanded
        } else if ProcessInfo.processInfo.arguments.contains("-testLoggingOverlay") {
            return .testLoggingOverlay
        } else if ProcessInfo.processInfo.arguments.contains("-testManualLogging") {
            return .testManualLogging
        } else if ProcessInfo.processInfo.arguments.contains("-testWeightGoalCutting") {
            return .testWeightGoalCutting
        } else if ProcessInfo.processInfo.arguments.contains("-testWeightGoalBulking") {
            return .testWeightGoalBulking
        } else if ProcessInfo.processInfo.arguments.contains("-testWeightGoal") {
            return .testWeightGoal
        } else if ProcessInfo.processInfo.arguments.contains("-testPersonalize") {
            return .testPersonalize
        } else if ProcessInfo.processInfo.arguments.contains("-testDashboard") {
            return .dashboard
        }
        return .splash
    }()

    @State private var testFoodItem: FoodItem = .dimsumMentai

    @State private var isTestEditSheetPresented = false

    var body: some View {
        switch screenState {
        case .splash:
            SplashScreenView(
                appName: "MacBite",
                tagline: "Your Macros, In a Snap",
                onFinish: {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        screenState = .onboarding
                    }
                }
            )

        case .onboarding:
            OnboardingFactory.makeView(onFinish: {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    screenState = .dashboard
                }
            })

        case .dashboard:
            DashboardFactory.makeView()

        case .testProfile:
            ProfileView()
                .preferredColorScheme(.dark)

        case .testFoodCard:
            ZStack {
                Color.black.ignoresSafeArea()
                AddFoodReviewCard(
                    foodItem: $testFoodItem,
                    isCompressed: true,
                    flipAngle: 180.0
                )
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .frame(width: 360, height: 620)
            }
            .preferredColorScheme(.dark)

        case .testFoodCardFront:
            ZStack {
                Color.black.ignoresSafeArea()
                AddFoodReviewCard(
                    foodItem: $testFoodItem,
                    isCompressed: false,
                    flipAngle: 0.0
                )
            }
            .preferredColorScheme(.dark)

        case .testEditSheet:
            ZStack {
                Color.black.ignoresSafeArea()
                AddFoodReviewCard(
                    foodItem: $testFoodItem,
                    isCompressed: false,
                    flipAngle: 0.0
                )
            }
            .sheet(isPresented: $isTestEditSheetPresented) {
                NutritionEditSheet(
                    field: .calories,
                    initialValue: testFoodItem.calories,
                    onSave: { updated in
                        testFoodItem.calories = updated
                        isTestEditSheetPresented = false
                    },
                    onCancel: {
                        isTestEditSheetPresented = false
                    }
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isTestEditSheetPresented = true
                }
            }
            .preferredColorScheme(.dark)

        case .testDashboardExpanded:
            testDashboardExpandedView

        case .testLoggingOverlay:
            testLoggingOverlayView

        case .testManualLogging:
            testManualLoggingView

        case .testPersonalize:
            NavigationStack {
                PersonalizeHealthView(viewModel: OnboardingViewModel())
            }
            .preferredColorScheme(.dark)

        case .testWeightGoal:
            NavigationStack {
                WeightGoalView(
                    currentWeightKg: 60.0,
                    targetWeightKg: nil,
                    heightCm: 168.0,
                    onBack: {}
                )
            }
            .preferredColorScheme(.dark)

        case .testWeightGoalCutting:
            NavigationStack {
                WeightGoalView(
                    currentWeightKg: 60.0,
                    targetWeightKg: 48.0,
                    heightCm: 168.0,
                    onBack: {}
                )
            }
            .preferredColorScheme(.dark)

        case .testWeightGoalBulking:
            NavigationStack {
                WeightGoalView(
                    currentWeightKg: 60.0,
                    targetWeightKg: 78.0,
                    heightCm: 168.0,
                    onBack: {}
                )
            }
            .preferredColorScheme(.dark)
        }
    }

    private var testLoggingOverlayView: some View {
        DashboardView(
            viewModel: {
                let vm = DashboardViewModel()
                vm.isShowingLoggingOptions = true
                return vm
            }()
        )
        .preferredColorScheme(.dark)
    }

    private var testManualLoggingView: some View {
        ManualLoggingView(
            viewModel: ManualLoggingViewModel(),
            onDismiss: {},
            onCalculate: { _, _ in }
        )
        .preferredColorScheme(.dark)
    }

    private var testDashboardExpandedView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            expandedContentColumn
        }
        .preferredColorScheme(.dark)
    }

    private var expandedContentColumn: some View {
        VStack(spacing: 0) {
            Spacer(minLength: AppSpacing.sm)
            CalorieProgressView(consumedCalories: 200, targetCalories: 2654)
            Spacer().frame(height: AppSpacing.md)
            Text("Heads up! You have 200 kcal remaining.\nConsider a lighter option for your next meal.")
                .font(AppTypography.subheadline)
                .foregroundStyle(Color(uiColor: .label))
                .multilineTextAlignment(.center)
            Spacer(minLength: AppSpacing.sm)
            MacroSummaryGridView(
                consumedCalories: 200,
                targetCalories: 2654,
                carbsGrams: 17,
                proteinGrams: 100,
                fatGrams: 17,
                fiberGrams: 100,
                initiallyExpanded: true
            )
            Spacer(minLength: AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.lg)
        .overlay(alignment: .bottomTrailing) {
            floatingAddButton
        }
    }

    private var floatingAddButton: some View {
        Button {} label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .accessibilityHidden(true)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .tint(.white)
        .padding(.trailing, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
        .accessibilityLabel("Add Food")
    }
}

private enum AppScreenState {
    case splash
    case onboarding
    case dashboard
    case testProfile
    case testFoodCard
    case testFoodCardFront
    case testEditSheet
    case testDashboardExpanded
    case testLoggingOverlay
    case testManualLogging
    case testPersonalize
    case testWeightGoal
    case testWeightGoalCutting
    case testWeightGoalBulking
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
