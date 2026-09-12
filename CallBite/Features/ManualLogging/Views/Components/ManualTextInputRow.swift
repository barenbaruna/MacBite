//
//  ManualTextInputRow.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct ManualTextInputRow: View {
    let title: String
    let placeholder: String
    let text: String
    let suffix: String?
    let onTextChanged: (String) -> Void

    init(
        title: String,
        placeholder: String,
        text: String,
        suffix: String? = nil,
        onTextChanged: @escaping (String) -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.suffix = suffix
        self.onTextChanged = onTextChanged
    }

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.white)
                .layoutPriority(1)

            Spacer(minLength: AppSpacing.small)

            HStack(spacing: AppSpacing.extraSmall) {
                TextField(placeholder, text: textBinding)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.manualInputForeground)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel(title)

                if let suffix {
                    Text(suffix)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.manualInputForeground)
                }
            }
        }
        .padding(.horizontal, AppSpacing.regular)
        .frame(minHeight: AppSize.manualInputRowHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { text },
            set: onTextChanged
        )
    }
}
