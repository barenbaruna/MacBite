//
//  PersonalizeFormCard.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Glass form card displaying health metrics summary rows.
struct PersonalizeFormCard: View {
    let formattedDate: String
    let selectedSex: BiologicalSex
    let selectedHeightCm: Int
    let selectedWeightKg: Int
    let activeField: PersonalizeField?
    let onSelectField: (PersonalizeField) -> Void

    var body: some View {
        VStack(spacing: .zero) {
            dataRow(title: "Date of Birth", value: formattedDate, field: .dateOfBirth)
            divider
            dataRow(title: "Sex", value: selectedSex.displayName, field: .sex)
            divider
            dataRow(title: "Height", value: "\(selectedHeightCm) cm", field: .height)
            divider
            dataRow(title: "Weight", value: "\(selectedWeightKg) kg", field: .weight)
        }
        .padding(.horizontal, AppSpacing.medium)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    private var divider: some View {
        Divider()
            .background(Color(uiColor: .separator).opacity(0.3))
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
        formattedDate: "14 Apr 1996",
        selectedSex: .female,
        selectedHeightCm: 162,
        selectedWeightKg: 72,
        activeField: .dateOfBirth,
        onSelectField: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
}
