//
//  WidgetMacroValueView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI

struct WidgetMacroValueView: View {
    let title: String
    let systemImage: String
    let consumed: Int
    let target: Int
    let color: Color

    var body: some View {
        HStack(spacing: WidgetSpacing.extraSmall) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: WidgetSpacing.medium)
                .accessibilityHidden(true)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: WidgetSpacing.extraSmall)

            Text("\(consumed)/\(target) g")
                .font(.caption.bold())
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(consumed) dari \(target) gram")
    }
}
