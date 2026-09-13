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
    case fiber = "Fiber"

    public var id: String { rawValue }

    public var unit: String {
        switch self {
        case .calories: return "kcal"
        case .protein, .carbs, .fat, .fiber: return "g"
        }
    }
}

/// Modal sheet for manually adjusting macronutrient values using a direct free text keypad.
public struct NutritionEditSheet: View {
    public let field: NutritionEditField
    public let initialValue: Int
    public let onSave: (Int) -> Void
    public let onCancel: () -> Void

    @State private var tempEditString: String
    @FocusState private var isFieldFocused: Bool

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

                freeTextInputRow

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
                        commitValue()
                    }
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.orange500)
                }
            }
            .onAppear {
                isFieldFocused = true
            }
        }
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(AppCornerRadius.sheet)
        .presentationBackground(AppColor.cardBackground)
    }

    private var freeTextInputRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
            TextField("0", text: $tempEditString)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(minWidth: 100, maxWidth: 200)
                .monospacedDigit()
                .foregroundStyle(Color(uiColor: .label))
                .focused($isFieldFocused)
                .accessibilityLabel("\(field.rawValue) input")

            Text(field.unit)
                .font(AppTypography.title2.weight(.semibold))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }

    private func commitValue() {
        let digitsOnly = tempEditString.filter { $0.isNumber }
        let value = max(0, Int(digitsOnly) ?? 0)
        onSave(value)
    }
}
