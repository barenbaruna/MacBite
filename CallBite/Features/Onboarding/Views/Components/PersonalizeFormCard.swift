//
//  PersonalizeFormCard.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Form card displaying health metrics summary rows (Age, Sex, Weight, Height).
struct PersonalizeFormCard: View {
    let selectedAge: Int
    let selectedSex: BiologicalSex
    let selectedWeightKg: Int
    let selectedHeightCm: Int
    let activeField: PersonalizeField?
    let onSelectField: (PersonalizeField) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            dataRow(title: "Age", value: "\(selectedAge) years", field: .age)
            divider
            dataRow(title: "Sex", value: selectedSex.displayName, field: .sex)
            divider
            dataRow(title: "Weight", value: "\(selectedWeightKg)kg", field: .weight)
            divider
            dataRow(title: "Height", value: "\(selectedHeightCm)cm", field: .height)
        }
        .padding(.horizontal, AppSpacing.large)
        .background(AppColor.activityCardNormal)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    private var divider: some View {
        Divider()
            .background(Color(uiColor: .separator).opacity(0.35))
    }

    private func dataRow(title: String, value: String, field: PersonalizeField) -> some View {
        let isActive = activeField == field

        return Button {
            onSelectField(field)
        } label: {
            HStack {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(Color(uiColor: .label))

                Spacer()

                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(isActive ? AppColor.orange400 : Color(uiColor: .secondaryLabel))
                    .contentTransition(.identity)
            }
            .contentShape(Rectangle())
            .padding(.vertical, AppSpacing.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PersonalizeFormCard(
        selectedAge: 22,
        selectedSex: .preferNotToSay,
        selectedWeightKg: 56,
        selectedHeightCm: 162,
        activeField: .age,
        onSelectField: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
}
