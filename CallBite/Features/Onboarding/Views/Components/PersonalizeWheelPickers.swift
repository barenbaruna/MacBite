//
//  PersonalizeWheelPickers.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Container presenting the active wheel picker for health personalization.
struct PersonalizeWheelPickers: View {
    let activeField: PersonalizeField?
    @Binding var selectedDay: Int
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var selectedSex: BiologicalSex
    @Binding var selectedHeightCm: Int
    @Binding var selectedWeightKg: Int
    let onDateChanged: () -> Void

    @ViewBuilder
    var body: some View {
        switch activeField {
        case .dateOfBirth:
            DateOfBirthWheelPicker(
                selectedDay: $selectedDay,
                selectedMonth: $selectedMonth,
                selectedYear: $selectedYear,
                onDateChanged: onDateChanged
            )
        case .sex:
            SexWheelPicker(selectedSex: $selectedSex)
        case .height:
            HeightWheelPicker(selectedHeightCm: $selectedHeightCm)
        case .weight:
            WeightWheelPicker(selectedWeightKg: $selectedWeightKg)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Date of Birth Wheel Picker

struct DateOfBirthWheelPicker: View {
    @Binding var selectedDay: Int
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    let onDateChanged: () -> Void

    private let fullMonthSymbols: [String] = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    var body: some View {
        HStack(spacing: .zero) {
            dayPicker
            monthPicker
            yearPicker
        }
        .onChange(of: selectedMonth) { _, _ in onDateChanged() }
        .onChange(of: selectedYear) { _, _ in onDateChanged() }
    }

    private var dayPicker: some View {
        Picker("Day", selection: $selectedDay) {
            ForEach(1...31, id: \.self) { day in
                Text("\(day)").tag(day)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }

    private var monthPicker: some View {
        Picker("Month", selection: $selectedMonth) {
            ForEach(1...12, id: \.self) { month in
                Text(fullMonthSymbols[month - 1]).tag(month)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }

    private var yearPicker: some View {
        Picker("Year", selection: $selectedYear) {
            ForEach(1920...2026, id: \.self) { year in
                Text(verbatim: "\(year)").tag(year)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Sex Wheel Picker

struct SexWheelPicker: View {
    @Binding var selectedSex: BiologicalSex

    var body: some View {
        Picker("Sex", selection: $selectedSex) {
            ForEach(BiologicalSex.selectableCases) { sex in
                Text(sex.displayName).tag(sex)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Height Wheel Picker

struct HeightWheelPicker: View {
    @Binding var selectedHeightCm: Int

    var body: some View {
        Picker("Height", selection: $selectedHeightCm) {
            ForEach(100...250, id: \.self) { height in
                Text("\(height) cm").tag(height)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weight Wheel Picker

struct WeightWheelPicker: View {
    @Binding var selectedWeightKg: Int

    var body: some View {
        Picker("Weight", selection: $selectedWeightKg) {
            ForEach(30...250, id: \.self) { weight in
                Text("\(weight) kg").tag(weight)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PersonalizeWheelPickers(
        activeField: .dateOfBirth,
        selectedDay: .constant(14),
        selectedMonth: .constant(4),
        selectedYear: .constant(1996),
        selectedSex: .constant(.female),
        selectedHeightCm: .constant(162),
        selectedWeightKg: .constant(72),
        onDateChanged: {}
    )
    .frame(height: 216)
    .preferredColorScheme(.dark)
}
