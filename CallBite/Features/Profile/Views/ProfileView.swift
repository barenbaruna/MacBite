//
//  ProfileView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 10/09/26.
//

import SwiftUI

/// User health profile view displaying biometric stats and allowing goal adjustments.
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        viewModel: ProfileViewModel? = nil,
        initialProfile: UserHealthProfile = UserHealthProfile(
            age: 22,
            biologicalSex: .preferNotToSay,
            weightKg: 56.0,
            heightCm: 162.0
        ),
        onSave: ((UserHealthProfile) -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ProfileViewModel(initialProfile: initialProfile, onSave: onSave)
        )
    }

    var body: some View {
        NavigationStack {
            profileContentStack
                .background(AppColor.backgroundGrouped)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .close) {
                            dismiss()
                        }
                        .accessibilityLabel("Dismiss Profile")
                    }
                }
                .sheet(isPresented: $viewModel.isShowingChangeGoal) {
                    changeGoalSheet
                }
                .sheet(item: $viewModel.activeFieldForEdit) { field in
                    editFieldSheet(for: field)
                        .presentationDetents([.height(280)])
                        .presentationDragIndicator(.visible)
                }
        }
    }

    // MARK: - Layout Hierarchy

    private var profileContentStack: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    changeGoalSection

                    healthDetailsSection
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.medium)
            }

            Spacer(minLength: 0)

            saveProfileButton
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.medium)
        }
    }

    // MARK: - Change Goal Section

    private var changeGoalSection: some View {
        Button {
            viewModel.isShowingChangeGoal = true
        } label: {
            HStack {
                Text("Change Goal")
                    .font(AppTypography.body.weight(.semibold))
                    .foregroundStyle(Color(uiColor: .label))

                Spacer()

                if let summary = viewModel.goalSummaryText {
                    Text(summary)
                        .font(AppTypography.body)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.medium)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Health Details Section

    private var healthDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Health Details")
                .font(AppTypography.headline.weight(.bold))
                .foregroundStyle(Color(uiColor: .label))

            healthDetailsCard
        }
    }

    private var healthDetailsCard: some View {
        VStack(spacing: 0) {
            healthDetailRow(
                title: "Age",
                value: "\(viewModel.age) years",
                action: { viewModel.activeFieldForEdit = .age }
            )

            rowDivider

            healthDetailRow(
                title: "Sex",
                value: viewModel.biologicalSex.displayName,
                action: { viewModel.activeFieldForEdit = .sex }
            )

            rowDivider

            healthDetailRow(
                title: "Weight",
                value: "\(Int(viewModel.weightKg))kg",
                action: { viewModel.activeFieldForEdit = .weight }
            )

            rowDivider

            healthDetailRow(
                title: "Height",
                value: "\(Int(viewModel.heightCm))cm",
                action: { viewModel.activeFieldForEdit = .height }
            )
        }
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }

    private var rowDivider: some View {
        Divider()
            .background(Color(uiColor: .separator).opacity(0.35))
            .padding(.horizontal, AppSpacing.medium)
    }

    private func healthDetailRow(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(Color(uiColor: .label))

                Spacer()

                HStack(spacing: 6) {
                    Text(value)
                        .font(AppTypography.body)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.medium)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save Profile Button

    private var saveProfileButton: some View {
        Button {
            viewModel.saveProfile()
            dismiss()
        } label: {
            Text("Save Profile")
                .font(AppTypography.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(AppColor.orange500)
    }
}

// MARK: - ProfileView Sheets & Editors

extension ProfileView {
    private var changeGoalSheet: some View {
        NavigationStack {
            WeightGoalView(
                currentWeightKg: viewModel.weightKg,
                targetWeightKg: viewModel.targetWeightKg,
                heightCm: viewModel.heightCm,
                showsDismissButton: true,
                onDone: { targetWeight, category in
                    viewModel.updateGoal(targetWeight: targetWeight, category: category)
                    viewModel.isShowingChangeGoal = false
                }
            )
        }
    }

    // MARK: - Inline Field Editor Sheet

    @ViewBuilder
    private func editFieldSheet(for field: ProfileField) -> some View {
        NavigationStack {
            fieldPickerContainer(for: field)
                .navigationTitle("Edit \(field.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            viewModel.activeFieldForEdit = nil
                        }
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColor.orange500)
                    }
                }
        }
    }

    @ViewBuilder
    private func fieldPickerContainer(for field: ProfileField) -> some View {
        VStack(spacing: 0) {
            switch field {
            case .age:
                agePickerView
            case .sex:
                sexPickerView
            case .weight:
                weightPickerView
            case .height:
                heightPickerView
            }
        }
    }

    private var agePickerView: some View {
        Picker("Age", selection: $viewModel.age) {
            ForEach(10...100, id: \.self) { age in
                Text("\(age) years").tag(age)
            }
        }
        .pickerStyle(.wheel)
    }

    private var sexPickerView: some View {
        Picker("Sex", selection: $viewModel.biologicalSex) {
            ForEach(BiologicalSex.selectableCases) { sex in
                Text(sex.displayName).tag(sex)
            }
        }
        .pickerStyle(.wheel)
    }

    private var weightPickerView: some View {
        Picker("Weight", selection: Binding(
            get: { Int(viewModel.weightKg) },
            set: { viewModel.weightKg = Double($0) }
        )) {
            ForEach(30...200, id: \.self) { kg in
                Text("\(kg) kg").tag(kg)
            }
        }
        .pickerStyle(.wheel)
    }

    private var heightPickerView: some View {
        Picker("Height", selection: Binding(
            get: { Int(viewModel.heightCm) },
            set: { viewModel.heightCm = Double($0) }
        )) {
            ForEach(100...250, id: \.self) { cm in
                Text("\(cm) cm").tag(cm)
            }
        }
        .pickerStyle(.wheel)
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
