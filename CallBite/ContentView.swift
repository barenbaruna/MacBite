//
//  ContentView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case addFood = 0
    case weightGoal = 1
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .addFood
    var onResetOnboarding: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            tabSection

            if let onResetOnboarding {
                replayButton(action: onResetOnboarding)
            }
        }
    }

    // MARK: - Subviews

    private var tabSection: some View {
        TabView(selection: $selectedTab) {
            SaveFoodAnimationProofView()
                .tabItem {
                    Label("Add Food", systemImage: "fork.knife")
                }
                .tag(AppTab.addFood)

            WeightGoalFactory.createView()
                .tabItem {
                    Label("Weight Goal", systemImage: "scalemass.fill")
                }
                .tag(AppTab.weightGoal)
        }
    }

    private func replayButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "arrow.counterclockwise")
                    .accessibilityHidden(true)
                Text("Replay Flow")
            }
            .font(AppTypography.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(.regularMaterial)
            .clipShape(Capsule())
        }
        .padding(.trailing, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .accessibilityLabel("Replay Onboarding Prototype")
    }
}

#Preview {
    ContentView()
}
