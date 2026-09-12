//
//  FoodNameEditSheet.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Modal sheet for renaming a detected/logged food item. Mirrors
//  NutritionEditSheet's visual language (compact custom sheet, cancel/done
//  toolbar) so editing the name feels consistent with editing the macros.
//

import SwiftUI

public struct FoodNameEditSheet: View {
    public let initialValue: String
    public let onSave: (String) -> Void
    public let onCancel: () -> Void

    @State private var tempName: String
    @FocusState private var isFieldFocused: Bool

    public init(
        initialValue: String,
        onSave: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialValue = initialValue
        self.onSave = onSave
        self.onCancel = onCancel
        self._tempName = State(initialValue: initialValue)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                nameField
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let trimmed = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmed.isEmpty ? initialValue : trimmed)
                    }
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.orange500)
                }
            }
            .onAppear { isFieldFocused = true }
        }
        .presentationDetents([.height(180)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(AppCornerRadius.sheet)
        .presentationBackground(AppColor.cardBackground)
    }

    private var nameField: some View {
        TextField("Food name", text: $tempName)
            .font(AppTypography.title3.weight(.semibold))
            .foregroundStyle(Color(uiColor: .label))
            .multilineTextAlignment(.center)
            .focused($isFieldFocused)
            .submitLabel(.done)
            .padding(AppSpacing.md)
            .background(Color(uiColor: .secondarySystemFill), in: RoundedRectangle(cornerRadius: AppCornerRadius.card))
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            FoodNameEditSheet(
                initialValue: "Dimsum Mentai",
                onSave: { _ in },
                onCancel: {}
            )
        }
        .preferredColorScheme(.dark)
}
