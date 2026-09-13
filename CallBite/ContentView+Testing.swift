//
//  ContentView+Testing.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

import SwiftUI

extension ContentView {
    @ViewBuilder
    func testView(for state: AppScreenState) -> some View {
        if let cardView = testCardOrProfileView(for: state) {
            cardView
        } else if let goalView = testInputOrGoalView(for: state) {
            goalView
        } else {
            EmptyView()
        }
    }

    private func testCardOrProfileView(for state: AppScreenState) -> AnyView? {
        switch state {
        case .testProfile:
            return AnyView(ProfileView().preferredColorScheme(.dark))
        case .testDashboardReview:
            return AnyView(testDashboardReviewView)
        case .testProfileChangeGoal:
            return AnyView(testProfileChangeGoalView)
        case .testFoodCard:
            return AnyView(testFoodCardView)
        case .testFoodCardFront:
            return AnyView(testFoodCardFrontView)
        case .testEditSheet:
            return AnyView(testEditSheetView)
        default:
            return nil
        }
    }

    private func testInputOrGoalView(for state: AppScreenState) -> AnyView? {
        switch state {
        case .testDashboardExpanded:
            return AnyView(testDashboardExpandedView)
        case .testLoggingOverlay:
            return AnyView(testLoggingOverlayView)
        case .testManualLogging:
            return AnyView(testManualLoggingView)
        case .testPersonalize:
            return AnyView(
                NavigationStack { PersonalizeHealthView(viewModel: OnboardingViewModel()) }
                    .preferredColorScheme(.dark)
            )
        case .testPersonalizeEditing:
            return AnyView(
                NavigationStack {
                    PersonalizeHealthView(viewModel: OnboardingViewModel(), initialActiveField: .age)
                }
                .preferredColorScheme(.dark)
            )
        case .testWeightGoal:
            return AnyView(
                NavigationStack {
                    WeightGoalView(currentWeightKg: 60.0, targetWeightKg: nil, heightCm: 168.0, onBack: {})
                }
                .preferredColorScheme(.dark)
            )
        case .testWeightGoalCutting:
            return AnyView(
                NavigationStack {
                    WeightGoalView(currentWeightKg: 60.0, targetWeightKg: 48.0, heightCm: 168.0, onBack: {})
                }
                .preferredColorScheme(.dark)
            )
        case .testWeightGoalBulking:
            return AnyView(
                NavigationStack {
                    WeightGoalView(currentWeightKg: 60.0, targetWeightKg: 78.0, heightCm: 168.0, onBack: {})
                }
                .preferredColorScheme(.dark)
            )
        default:
            return nil
        }
    }

    private var testDashboardReviewView: some View {
        DashboardView(
            viewModel: {
                let viewModel = DashboardViewModel()
                viewModel.isShowingAddFood = true
                return viewModel
            }()
        )
        .preferredColorScheme(.dark)
    }

    private var testProfileChangeGoalView: some View {
        ProfileView(
            viewModel: {
                let vm = ProfileViewModel(
                    initialProfile: UserHealthProfile(
                        age: 22,
                        biologicalSex: .preferNotToSay,
                        weightKg: 56.0,
                        heightCm: 162.0
                    )
                )
                vm.isShowingChangeGoal = true
                return vm
            }()
        )
        .preferredColorScheme(.dark)
    }

    private var testFoodCardView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AddFoodReviewCard(
                foodItem: $testFoodItem,
                isCompressed: false,
                flipAngle: 180.0
            )
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .preferredColorScheme(.dark)
    }

    private var testFoodCardFrontView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AddFoodReviewCard(
                foodItem: $testFoodItem,
                isCompressed: false,
                flipAngle: 0.0
            )
        }
        .preferredColorScheme(.dark)
    }

    private var testEditSheetView: some View {
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
