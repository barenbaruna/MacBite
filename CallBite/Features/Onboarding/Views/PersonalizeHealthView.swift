//
//  PersonalizeHealthView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Active field being edited in the health personalization form.
private enum PersonalizeField: Hashable {
    case dateOfBirth
    case sex
    case height
    case weight
}

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

    private var fullMonthSymbols: [String] {
        [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            titleSection
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)

            formCard
                .padding(.bottom, AppSpacing.md)

            if activeField != nil {
                middleDoneButton
                    .padding(.bottom, AppSpacing.sm)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Spacer(minLength: 0)

            if activeField != nil {
                bottomPickerContainer
                    .frame(height: 216)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                continueButton
                    .padding(.bottom, AppSpacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .background(Color(uiColor: .systemBackground))
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(activeField != nil)
        .toolbar {
            if activeField != nil {
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
        .onAppear {
            initializeDefaultsFromProfile()
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Personalize Fitness and Health")
                .font(AppTypography.title2.weight(.bold))
                .foregroundStyle(Color(uiColor: .label))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(
                "This information ensures Fitness and Health data are as accurate as possible. " +
                "These details are not shared with Apple."
            )
            .font(AppTypography.subheadline)
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 0) {
            dataRow(
                title: "Date of Birth",
                value: formattedDateString,
                field: .dateOfBirth
            )

            Divider().background(Color(uiColor: .separator).opacity(0.3))

            dataRow(
                title: "Sex",
                value: selectedSex.displayName,
                field: .sex
            )

            Divider().background(Color(uiColor: .separator).opacity(0.3))

            dataRow(
                title: "Height",
                value: "\(selectedHeightCm) cm",
                field: .height
            )

            Divider().background(Color(uiColor: .separator).opacity(0.3))

            dataRow(
                title: "Weight",
                value: "\(selectedWeightKg) kg",
                field: .weight
            )
        }
        .padding(.horizontal, AppSpacing.md)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    private func dataRow(title: String, value: String, field: PersonalizeField) -> some View {
        let isActive = activeField == field

        return Button {
            startEditing(field: field)
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
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Middle Done Button (Edit Mode - Native Liquid Glass Standard Size)

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

    // MARK: - Bottom Continue Button (Normal Mode - Native Liquid Glass Standard Size)

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

    // MARK: - Bottom Picker Container (Edit Mode)

    @ViewBuilder
    private var bottomPickerContainer: some View {
        switch activeField {
        case .dateOfBirth:
            dateOfBirthWheelPicker
        case .sex:
            sexWheelPicker
        case .height:
            heightWheelPicker
        case .weight:
            weightWheelPicker
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Wheel Pickers

private extension PersonalizeHealthView {
    var dateOfBirthWheelPicker: some View {
        HStack(spacing: 0) {
            Picker("Day", selection: $selectedDay) {
                ForEach(1...31, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Picker("Month", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { Text(fullMonthSymbols[$0 - 1]).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Picker("Year", selection: $selectedYear) {
                ForEach(1920...2026, id: \.self) { Text(verbatim: "\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .onChange(of: selectedMonth) { _, newMonth in clampDayForMonth(newMonth, year: selectedYear) }
        .onChange(of: selectedYear) { _, newYear in clampDayForMonth(selectedMonth, year: newYear) }
    }

    var sexWheelPicker: some View {
        Picker("Sex", selection: $selectedSex) {
            ForEach(BiologicalSex.selectableCases) { sex in
                Text(sex.displayName).tag(sex)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }

    var heightWheelPicker: some View {
        Picker("Height", selection: $selectedHeightCm) {
            ForEach(100...250, id: \.self) { Text("\($0) cm").tag($0) }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }

    var weightWheelPicker: some View {
        Picker("Weight", selection: $selectedWeightKg) {
            ForEach(30...250, id: \.self) { Text("\($0) kg").tag($0) }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
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
            if selectedDay > range.count { selectedDay = range.count }
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
        PersonalizeHealthView(viewModel: OnboardingViewModel())
    }
    .preferredColorScheme(.dark)
}
