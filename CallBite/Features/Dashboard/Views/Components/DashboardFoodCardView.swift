//
//  DashboardFoodCardView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 10/09/26.
//

import SwiftUI
import UIKit

struct DashboardFoodCardView: View {
    let food: FoodItem
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            AppHaptics.primaryAction()
            onTap?()
        } label: {
            ZStack(alignment: .leading) {
                background
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSize.dashboardFoodCardHeight)
                    .clipped()

                AppGradient.foodCardOverlay

                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                    Text(food.mealType)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColor.white)

                    Text(food.name)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColor.foodCardName)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, AppSpacing.dashboardFoodCardContentInset)
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSize.dashboardFoodCardHeight)
            .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(food.mealType), \(food.name)")
    }

    @ViewBuilder
    private var background: some View {
        if let photoData = food.photoData,
           let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else if let assetName = food.photoAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            AppGradient.foodCardFallback
        }
    }
}

#Preview {
    DashboardFoodCardView(food: .dimsumMentai)
        .padding()
        .preferredColorScheme(.dark)
}
