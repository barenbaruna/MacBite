//
//  SaveFoodProofComponents.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

// MARK: - Add Food Card Content (Native NavigationStack & Toolbar)
struct AddFoodCardContent: View {
    @Binding var foodItem: FoodItem
    let isCompressed: Bool
    let onDismiss: () -> Void
    let onSave: () -> Void
    let isSaveDisabled: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.sm) {
                presetPickerRow
                photoPlaceholderCard
                mealBadgeRow
                nutritionCard
                Spacer(minLength: AppSpacing.xs)
                saveButton
            }
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, isCompressed ? AppSpacing.sm : AppSpacing.md)
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close, action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(width: 32, height: 32)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Circle())
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityLabel("Dismiss")
                }
            }
        }
    }

    private var presetPickerRow: some View {
        HStack {
            Text("Test Preset:")
                .font(.caption.bold())
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            Picker("Test Preset", selection: $foodItem) {
                ForEach(FoodItem.allPresets) { item in
                    Label(item.name, systemImage: item.photoSystemName).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(Color(.label))
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, 4)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private var photoPlaceholderCard: some View {
        RoundedRectangle(cornerRadius: AppCornerRadius.large)
            .fill(Color(.secondarySystemBackground))
            .frame(height: isCompressed ? 160 : 190)
            .overlay(
                Image(systemName: foodItem.photoSystemName)
                    .font(.system(size: 54))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .accessibilityHidden(true)
            )
            .padding(.horizontal, AppSpacing.lg)
    }

    private var mealBadgeRow: some View {
        HStack(spacing: AppSpacing.xs) {
            Text(foodItem.mealType)
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray))
                .clipShape(Capsule())

            Text(foodItem.dateString)
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(foodItem.name)
                .font(.title3.bold())
                .foregroundStyle(Color(.label))
                .padding(.bottom, 2)

            nutritionRow(title: "Calories", value: "\(foodItem.calories)kcal")
            Divider().background(Color(.separator))
            nutritionRow(title: "Protein", value: "\(foodItem.protein)g")
            Divider().background(Color(.separator))
            nutritionRow(title: "Carbs", value: "\(foodItem.carbs)g")
            Divider().background(Color(.separator))
            nutritionRow(title: "Fat", value: "\(foodItem.fat)g")
        }
        .padding(AppSpacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
        .padding(.horizontal, AppSpacing.lg)
    }

    private func nutritionRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color(.label))
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color(.secondaryLabel))
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(Color(.tertiaryLabel))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 2)
    }

    private var saveButton: some View {
        Button(action: onSave) {
            Text("Save Food")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Color(.systemGray))
        .clipShape(Capsule())
        .disabled(isSaveDisabled)
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Saved Confirmation Content (Floating Rounded Card)
struct SavedConfirmationContent: View {
    let foodItem: FoodItem
    let isSymbolActive: Bool

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(.systemGray))
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }
            .symbolEffect(.bounce.byLayer, value: isSymbolActive)

            Text("Your Food has been Saved")
                .font(.title3.bold())
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)

            Text("+\(foodItem.calories) kcal from \(foodItem.name)")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
        }
        .padding(AppSpacing.xl)
        .background(Color(.systemBackground))
    }
}

// MARK: - Dashboard Supporting Views
enum DashboardSupportingViews {
    static func header(onProfileTap: (() -> Void)? = nil) -> some View {
        HStack {
            Text("Today, 4 Sep 2026")
                .font(.headline)
                .foregroundStyle(Color(.label))
            Spacer()
            HStack(spacing: AppSpacing.xs) {
                iconButton(systemName: "calendar")
                if let onProfileTap {
                    Button(action: onProfileTap) {
                        iconButton(systemName: "person")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Profile & Weight Goal")
                } else {
                    iconButton(systemName: "person")
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
    }

    static var streakBadge: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundStyle(Color(.secondaryLabel))
                .accessibilityHidden(true)
            Text("0 DAY")
                .font(.caption2.bold())
                .foregroundStyle(Color(.label))
            Text("STREAK")
                .font(.caption2)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 6)
        .background(Color(.tertiarySystemFill))
        .clipShape(Capsule())
    }

    static func totalForBulkCard(caloriesText: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Total for Bulk")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
            Text(caloriesText)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.label))
                .contentTransition(.numericText())
            Divider().background(Color(.separator))
            HStack {
                Text("Protein").font(.subheadline).foregroundStyle(Color(.secondaryLabel))
                Spacer()
                Text("Carbs").font(.subheadline).foregroundStyle(Color(.secondaryLabel))
            }
        }
        .padding(AppSpacing.lg)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
    }

    private static func iconButton(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.body)
            .foregroundStyle(Color(.secondaryLabel))
            .frame(width: 36, height: 36)
            .background(Color(.secondarySystemFill))
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

// MARK: - Energy Droplet Orb View (Food Nutrient Particle)
struct EnergyDropletOrbView: View {
    let scale: CGFloat
    let blur: CGFloat
    let opacity: Double

    var body: some View {
        ZStack {
            // Pendaran aura energi luar
            Circle()
                .fill(Color(.systemGray).opacity(0.35))
                .frame(width: 72, height: 72)
                .blur(radius: 14)

            // Inti gradien radial
            Circle()
                .fill(RadialGradient(
                    colors: [.white, Color(.systemGray3), Color(.systemGray)],
                    center: .center,
                    startRadius: 2,
                    endRadius: 22
                ))
                .frame(width: 46, height: 46)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 2)

            Image(systemName: "fork.knife")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(.darkGray))
                .accessibilityHidden(true)
        }
        .scaleEffect(scale)
        .blur(radius: blur)
        .opacity(opacity)
    }
}
