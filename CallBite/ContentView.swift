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

    var body: some View {
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
}

#Preview {
    ContentView()
}
