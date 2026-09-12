//
//  DashboardFoodHistorySection.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import SwiftUI

struct DashboardFoodHistorySection: View {
    let foods: [FoodItem]
    var onFoodTap: ((FoodItem) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.regular) {
            Text("My Meals")
                .font(AppTypography.headline)
                .foregroundStyle(Color(uiColor: .label))
                .padding(.leading, AppSpacing.dashboardFoodSectionHeaderInset)

            if foods.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: AppSpacing.dashboardFoodCardSpacing) {
                    ForEach(foods) { food in
                        DashboardFoodCardView(food: food) {
                            onFoodTap?(food)
                        }
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        HStack(spacing: AppSpacing.regular) {
            ZStack {
                Circle()
                    .fill(AppColor.orange500.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppColor.orange400)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("No meals logged yet")
                    .font(AppTypography.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.white)

                Text("Tap + below to capture or log your food")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.gray300)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.md)
        .background(AppColor.activityCardNormal)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous)
                .strokeBorder(AppColor.borderSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    DashboardFoodHistorySection(foods: FoodItem.allPresets)
        .padding()
        .preferredColorScheme(.dark)
}
