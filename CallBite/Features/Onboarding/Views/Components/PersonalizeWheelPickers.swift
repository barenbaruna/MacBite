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
    @Binding var selectedAge: Int
    @Binding var selectedSex: BiologicalSex
    @Binding var selectedWeightKg: Int
    @Binding var selectedHeightCm: Int

    @ViewBuilder
    var body: some View {
        switch activeField {
        case .age:
            AgeWheelPicker(selectedAge: $selectedAge)
        case .sex:
            SexWheelPicker(selectedSex: $selectedSex)
        case .weight:
            WeightWheelPicker(selectedWeightKg: $selectedWeightKg)
        case .height:
            HeightWheelPicker(selectedHeightCm: $selectedHeightCm)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Age Wheel Picker

struct AgeWheelPicker: View {
    @Binding var selectedAge: Int

    var body: some View {
        Picker("Age", selection: $selectedAge) {
            ForEach(10...100, id: \.self) { age in
                Text("\(age) years").tag(age)
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

#Preview {
    PersonalizeWheelPickers(
        activeField: .age,
        selectedAge: .constant(22),
        selectedSex: .constant(.preferNotToSay),
        selectedWeightKg: .constant(56),
        selectedHeightCm: .constant(162)
    )
    .frame(height: 216)
    .preferredColorScheme(.dark)
}
