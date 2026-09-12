//
//  PersonalizeHealthView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Manual health data entry view supporting both presentation and wheel-picker editing modes.
struct PersonalizeHealthView: View {
    @ObservedObject private var viewModel: OnboardingViewModel

    @State private var selectedAge: Int = 22
    @State private var selectedSex: BiologicalSex = .preferNotToSay
    @State private var selectedWeightKg: Int = 56
    @State private var selectedHeightCm: Int = 162

    @State private var activeField: PersonalizeField?

    // Snapshot state for rollback on cancellation
    @State private var snapshotAge: Int = 22
    @State private var snapshotSex: BiologicalSex = .preferNotToSay
    @State private var snapshotWeightKg: Int = 56
    @State private var snapshotHeightCm: Int = 162

    init(
        viewModel: OnboardingViewModel,
        initialActiveField: PersonalizeField? = nil
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._activeField = State(initialValue: initialActiveField)
    }

    var body: some View {
        VStack(spacing: .zero) {
            titleSection
                .padding(.top, AppSpacing.medium)
                .padding(.bottom, AppSpacing.extraLarge)

            PersonalizeFormCard(
                selectedAge: selectedAge,
                selectedSex: selectedSex,
                selectedWeightKg: selectedWeightKg,
                selectedHeightCm: selectedHeightCm,
                activeField: activeField,
                onSelectField: startEditing
            )
            .padding(.bottom, AppSpacing.medium)

            if activeField != nil {
                middleDoneButton
                    .padding(.bottom, AppSpacing.small)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Spacer(minLength: .zero)

            bottomSection
        }
        .padding(.horizontal, AppSpacing.large)
        .background(Color(uiColor: .systemBackground))
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(activeField != nil)
        .toolbar {
            if activeField != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: cancelEditing) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel editing")
                }
            }
        }
        .onAppear {
            initializeDefaultsFromProfile()
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Personalize Fitness and Health")
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(uiColor: .label))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(
                "We use the information you share to personalize your daily calorie and macronutrients needs."
            )
            .font(AppTypography.body)
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Buttons & Bottom Section

    private var middleDoneButton: some View {
        Button(action: doneEditing) {
            Text("Done")
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.orange500)
    }

    private var continueButton: some View {
        Button(action: saveAndContinue) {
            Text("Continue")
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.orange500)
    }

    @ViewBuilder
    private var bottomSection: some View {
        if activeField != nil {
            PersonalizeWheelPickers(
                activeField: activeField,
                selectedAge: $selectedAge,
                selectedSex: $selectedSex,
                selectedWeightKg: $selectedWeightKg,
                selectedHeightCm: $selectedHeightCm
            )
            .frame(height: 216)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            continueButton
                .padding(.bottom, AppSpacing.extraLarge)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Actions & Mode Switching

private extension PersonalizeHealthView {
    func startEditing(field: PersonalizeField) {
        if activeField == nil { snapshotCurrentValues() }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { activeField = field }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func doneEditing() {
        snapshotCurrentValues()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { activeField = nil }
    }

    func cancelEditing() {
        restoreSnapshotValues()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { activeField = nil }
    }

    func snapshotCurrentValues() {
        snapshotAge = selectedAge
        snapshotSex = selectedSex
        snapshotWeightKg = selectedWeightKg
        snapshotHeightCm = selectedHeightCm
    }

    func restoreSnapshotValues() {
        selectedAge = snapshotAge
        selectedSex = snapshotSex
        selectedWeightKg = snapshotWeightKg
        selectedHeightCm = snapshotHeightCm
    }

    func initializeDefaultsFromProfile() {
        let profile = viewModel.healthProfile
        if profile.age > 0 {
            selectedAge = profile.age
        }
        if profile.biologicalSex != .notSet {
            selectedSex = profile.biologicalSex
        } else {
            selectedSex = .preferNotToSay
        }
        if profile.weightKg > 0 {
            selectedWeightKg = Int(profile.weightKg.rounded())
        }
        if profile.heightCm > 0 {
            selectedHeightCm = Int(profile.heightCm.rounded())
        }
        snapshotCurrentValues()
    }

    func saveAndContinue() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        viewModel.saveManualProfile(
            age: selectedAge,
            sex: selectedSex,
            heightCm: Double(selectedHeightCm),
            weightKg: Double(selectedWeightKg)
        )
    }
}

#Preview {
    NavigationStack {
        PersonalizeHealthView(viewModel: OnboardingFactory.makePreviewViewModel())
    }
    .preferredColorScheme(.dark)
}
