//
//  NutritionEditSheet.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 10/09/26.
//

import SwiftUI

/// Macronutrient fields available for manual editing.
public enum NutritionEditField: String, Identifiable, CaseIterable {
    case calories = "Calories"
    case protein = "Protein"
    case carbs = "Carbs"
    case fat = "Fat"

    public var id: String { rawValue }

    public var unit: String {
        switch self {
        case .calories: return "kcal"
        case .protein, .carbs, .fat: return "g"
        }
    }

    public var step: Int {
        switch self {
        case .calories: return 10
        case .protein, .carbs, .fat: return 1
        }
    }

    public var quickAddAmounts: [Int] {
        switch self {
        case .calories: return [10, 50, 100]
        case .protein, .carbs, .fat: return [1, 5, 10]
        }
    }
}

/// Modal sheet for manually adjusting macronutrient values using keypad, steppers, and quick pills.
public struct NutritionEditSheet: View {
    public let field: NutritionEditField
    public let initialValue: Int
    public let onSave: (Int) -> Void
    public let onCancel: () -> Void

    @State private var tempEditString: String

    public init(
        field: NutritionEditField,
        initialValue: Int,
        onSave: @escaping (Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.field = field
        self.initialValue = initialValue
        self.onSave = onSave
        self.onCancel = onCancel
        self._tempEditString = State(initialValue: "\(initialValue)")
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Spacer()

                stepperAndValueRow

                quickAddPillsRow

                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .navigationTitle("Edit \(field.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let digitsOnly = tempEditString.filter { $0.isNumber }
                        let value = max(0, Int(digitsOnly) ?? 0)
                        onSave(value)
                    }
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.orange500)
                }
            }
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(AppCornerRadius.sheet)
        .presentationBackground(AppColor.cardBackground)
    }

    private var stepperAndValueRow: some View {
        HStack(spacing: AppSpacing.md) {
            minusStepperButton
            valueDisplayField
            plusStepperButton
        }
    }

    private var minusStepperButton: some View {
        Button {
            adjustTempValue(by: -field.step)
        } label: {
            Image(systemName: "minus")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(uiColor: .label))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Decrease \(field.rawValue)")
    }

    private var plusStepperButton: some View {
        Button {
            adjustTempValue(by: field.step)
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(uiColor: .label))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Increase \(field.rawValue)")
    }

    private var valueDisplayField: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            TextField("0", text: $tempEditString)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(minWidth: 90, maxWidth: 150)
                .monospacedDigit()
                .foregroundStyle(Color(uiColor: .label))

            Text(field.unit)
                .font(AppTypography.title3.weight(.semibold))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }

    private var quickAddPillsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(field.quickAddAmounts, id: \.self) { amount in
                Button("+\(amount)\(field.unit)") {
                    adjustTempValue(by: amount)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .controlSize(.regular)
            }
        }
    }

    private func adjustTempValue(by delta: Int) {
        let digitsOnly = tempEditString.filter { $0.isNumber }
        let current = Int(digitsOnly) ?? 0
        let updated = max(0, current + delta)
        tempEditString = "\(updated)"
    }
}
