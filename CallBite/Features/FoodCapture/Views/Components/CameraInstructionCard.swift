//
//  CameraInstructionCard.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 12/09/26.
//

import SwiftUI

struct CameraInstructionCard: View {
    let guidance: CameraPositionGuidance

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: "viewfinder")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(AppColor.white)
                .frame(width: AppSpacing.large)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .zero) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.white)

                Text(subtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColor.gray200)
            }

            Spacer(minLength: .zero)
        }
        .padding(.horizontal, AppSpacing.cameraInstructionContentInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.cameraInstructionBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: AppSize.cameraInstructionCornerRadius)
        )
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        switch guidance {
        case .placeMeal:
            "Place your meal in the guide"
        case .moveCloser:
            "Move Closer"
        case .moveBack:
            "Move Back"
        case .centerPlate:
            "Center Your Plate"
        case .ready:
            "Plate Position Ready"
        }
    }

    private var subtitle: String {
        switch guidance {
        case .placeMeal, .moveBack, .ready:
            "Keep the whole plate visible."
        case .moveCloser:
            "Fill at least 30% of the guide."
        case .centerPlate:
            "Align the plate with the safe area."
        }
    }
}
