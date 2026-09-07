//
//  WeightGoalView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

struct WeightGoalView: View {
    @State private var viewModel: WeightGoalViewModel
    @Environment(\.dismiss) private var dismiss
    var onDone: ((Double, GoalCategory) -> Void)?

    init(
        currentWeightKg: Double = 60.0,
        targetWeightKg: Double = 56.0,
        heightCm: Double = 168.0,
        onDone: ((Double, GoalCategory) -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: WeightGoalViewModel(
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                heightCm: heightCm
            )
        )
        self.onDone = onDone
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        headerSection

                        weightGoalDisplaySection
                            .frame(maxWidth: .infinity, alignment: .center)

                        activeCategoryBadge

                        sliderSection

                        Divider()
                            .background(Color(.separator))
                            .padding(.top, AppSpacing.xs)

                        noteAndAdviceSection
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }

                bottomBarSection
            }
            .background(Color(.systemBackground))
        }
        .sensoryFeedback(.selection, trigger: viewModel.triggerCategoryHaptic)
    }
}

// MARK: - View Components
private extension WeightGoalView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.insight.headline)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(.label))
                .contentTransition(.numericText())

            Text(viewModel.insight.subtitle)
                .font(.body)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var weightGoalDisplaySection: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text("Weight Goal")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color(.label))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(viewModel.targetWeightKg.rounded()))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(.label))
                    .contentTransition(.numericText())

                Text("kg")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(.label))
            }
            .animation(.smooth(duration: 0.2), value: viewModel.targetWeightKg)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    var activeCategoryBadge: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: categoryIcon)
                .font(.caption.bold())
                .foregroundStyle(Color(.secondaryLabel))

            Text(viewModel.activeCategory.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(.label))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemFill))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
        .contentTransition(.opacity)
        .animation(.smooth(duration: 0.25), value: viewModel.activeCategory)
    }

    private var categoryIcon: String {
        switch viewModel.activeCategory {
        case .cutting:
            return "arrow.down.right"
        case .maintaining:
            return "equal"
        case .bulking:
            return "arrow.up.right"
        }
    }

    var sliderSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ScientificWeightSlider(
                value: $viewModel.targetWeightKg,
                range: viewModel.minSliderWeight...viewModel.maxSliderWeight
            )

            VStack(spacing: 2) {
                Text("Recommended ideal weight:")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))

                Text("a healthy and realistic range based on your profile.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppSpacing.xxs)
        }
    }

    var noteAndAdviceSection: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(noteText)
                .font(.body)
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .center)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: viewModel.activeCategory)
        }
        .padding(.vertical, AppSpacing.lg)
    }

    private var noteText: String {
        switch viewModel.activeCategory {
        case .cutting:
            return "Target penurunan berat badan membutuhkan defisit kalori teratur (~500 kkal/hari). " +
                   "Konsumsi protein cukup agar massa otot tetap terjaga."
        case .maintaining:
            return "Mempertahankan berat badan saat ini dengan asupan kalori seimbang (TDEE). " +
                   "Sangat baik untuk kestabilan metabolisme tubuh."
        case .bulking:
            return "Target penambahan massa otot membutuhkan surplus terukur (~300 kkal/hari) " +
                   "diimbangi latihan beban progresif untuk hasil optimal."
        }
    }

    var bottomBarSection: some View {
        VStack(spacing: 0) {
            Button {
                onDone?(viewModel.targetWeightKg, viewModel.activeCategory)
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundStyle(.white)
                    .background(Color(.systemGray))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.md)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    WeightGoalView(currentWeightKg: 60.0, targetWeightKg: 56.0, heightCm: 168.0)
}
