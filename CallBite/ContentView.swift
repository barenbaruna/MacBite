//
//  ContentView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var screenState: AppScreenState = ContentView.initialScreenState()
    @State var testFoodItem: FoodItem = .dimsumMentai
    @State var isTestEditSheetPresented = false

    @StateObject private var dashboardViewModel = DashboardViewModel()

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
                if let goal = UserProfileStore.shared.nutritionGoal {
                    dashboardViewModel.updateNutritionTargets(goal)
                }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    screenState = .dashboard
                }
            })

        case .dashboard:
            DashboardView(viewModel: dashboardViewModel)

        default:
            testView(for: screenState)
        }
    }

    private static let testScreenArguments: [(String, AppScreenState)] = [
        ("-testProfileChangeGoal", .testProfileChangeGoal),
        ("-testProfile", .testProfile),
        ("-testDashboardReview", .testDashboardReview),
        ("-testEditSheet", .testEditSheet),
        ("-testFoodCardFront", .testFoodCardFront),
        ("-testFoodCard", .testFoodCard),
        ("-testDashboardExpanded", .testDashboardExpanded),
        ("-testLoggingOverlay", .testLoggingOverlay),
        ("-testManualLogging", .testManualLogging),
        ("-testWeightGoalCutting", .testWeightGoalCutting),
        ("-testWeightGoalBulking", .testWeightGoalBulking),
        ("-testWeightGoal", .testWeightGoal),
        ("-testPersonalizeEditing", .testPersonalizeEditing),
        ("-testPersonalize", .testPersonalize),
        ("-testDashboard", .dashboard)
    ]

    private static func initialScreenState() -> AppScreenState {
        let args = ProcessInfo.processInfo.arguments
        for (flag, screen) in testScreenArguments where args.contains(flag) {
            return screen
        }

        if UserProfileStore.shared.hasCompletedOnboarding {
            return .dashboard
        }

        return .splash
    }
}

enum AppScreenState {
    case splash
    case onboarding
    case dashboard
    case testProfile
    case testDashboardReview
    case testProfileChangeGoal
    case testFoodCard
    case testFoodCardFront
    case testEditSheet
    case testDashboardExpanded
    case testLoggingOverlay
    case testManualLogging
    case testPersonalize
    case testPersonalizeEditing
    case testWeightGoal
    case testWeightGoalCutting
    case testWeightGoalBulking
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
