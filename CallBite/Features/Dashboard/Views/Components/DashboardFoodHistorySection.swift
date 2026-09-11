//
//  DashboardFoodHistorySection.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import SwiftUI

struct DashboardFoodHistorySection: View {
    let foods: [FoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.regular) {
            Text("My Meals")
                .font(AppTypography.headline)
                .foregroundStyle(Color(uiColor: .label))
                .padding(.leading, AppSpacing.dashboardFoodSectionHeaderInset)

            LazyVStack(spacing: AppSpacing.dashboardFoodCardSpacing) {
                ForEach(foods) { food in
                    DashboardFoodCardView(food: food)
                }
            }
        }
    }
}

#Preview {
    DashboardFoodHistorySection(foods: FoodItem.allPresets)
        .padding()
        .preferredColorScheme(.dark)
}
