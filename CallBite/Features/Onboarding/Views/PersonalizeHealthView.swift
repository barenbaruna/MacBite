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

    @State private var selectedDay: Int = 14
    @State private var selectedMonth: Int = 4
    @State private var selectedYear: Int = 1996
    @State private var selectedSex: BiologicalSex = .female
    @State private var selectedHeightCm: Int = 162
    @State private var selectedWeightKg: Int = 72

    @State private var activeField: PersonalizeField?

    // Snapshot state for rollback on cancellation
    @State private var snapshotDay: Int = 14
    @State private var snapshotMonth: Int = 4
    @State private var snapshotYear: Int = 1996
    @State private var snapshotSex: BiologicalSex = .female
    @State private var snapshotHeightCm: Int = 162
    @State private var snapshotWeightKg: Int = 72

    init(viewModel: OnboardingViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    private var formattedDateString: String {
        let monthSymbols = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ]
        let monthName = monthSymbols[max(0, min(11, selectedMonth - 1))]
        return "\(selectedDay) \(monthName) \(selectedYear)"
    }

    var body: some View {
        VStack(spacing: .zero) {
            titleSection
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.large)

            PersonalizeFormCard(
                formattedDate: formattedDateString,
                selectedSex: selectedSex,
                selectedHeightCm: selectedHeightCm,
                selectedWeightKg: selectedWeightKg,
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
                editingToolbar
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
                .font(AppTypography.title1.weight(.bold))
                .foregroundStyle(Color(uiColor: .label))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(
                "We use the information you share to personalize your daily calorie and macronutrients needs."
            )
            .font(AppTypography.subheadline)
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
                selectedDay: $selectedDay,
                selectedMonth: $selectedMonth,
                selectedYear: $selectedYear,
                selectedSex: $selectedSex,
                selectedHeightCm: $selectedHeightCm,
                selectedWeightKg: $selectedWeightKg,
                onDateChanged: { clampDayForMonth(selectedMonth, year: selectedYear) }
            )
            .frame(height: 216)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            continueButton
                .padding(.bottom, AppSpacing.extraLarge)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ToolbarContentBuilder
    private var editingToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                cancelEditing()
            }
            .tint(AppColor.orange500)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Done") {
                doneEditing()
            }
            .buttonStyle(.glassProminent)
            .tint(AppColor.orange500)
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
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { activeField = nil }
    }

    func cancelEditing() {
        restoreSnapshotValues()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { activeField = nil }
    }

    func snapshotCurrentValues() {
        snapshotDay = selectedDay
        snapshotMonth = selectedMonth
        snapshotYear = selectedYear
        snapshotSex = selectedSex
        snapshotHeightCm = selectedHeightCm
        snapshotWeightKg = selectedWeightKg
    }

    func restoreSnapshotValues() {
        selectedDay = snapshotDay
        selectedMonth = snapshotMonth
        selectedYear = snapshotYear
        selectedSex = snapshotSex
        selectedHeightCm = snapshotHeightCm
        selectedWeightKg = snapshotWeightKg
    }

    func clampDayForMonth(_ month: Int, year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        let calendar = Calendar.current
        if let date = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: date) {
            if selectedDay > range.count {
                selectedDay = range.count
            }
        }
    }

    func initializeDefaultsFromProfile() {
        let profile = viewModel.healthProfile
        if profile.age > 0 {
            let currentYear = Calendar.current.component(.year, from: Date())
            selectedYear = max(1920, currentYear - profile.age)
        }
        if profile.biologicalSex != .notSet { selectedSex = profile.biologicalSex }
        if profile.heightCm > 0 { selectedHeightCm = Int(profile.heightCm.rounded()) }
        if profile.weightKg > 0 { selectedWeightKg = Int(profile.weightKg.rounded()) }
        snapshotCurrentValues()
    }

    func saveAndContinue() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = selectedDay
        let birthDate = Calendar.current.date(from: components) ?? Date()

        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        let calculatedAge = max(1, ageComponents.year ?? 25)

        viewModel.saveManualProfile(
            age: calculatedAge,
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
