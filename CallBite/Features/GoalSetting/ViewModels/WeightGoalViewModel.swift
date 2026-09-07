//
//  WeightGoalViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 07/09/26.
//

import SwiftUI

@Observable
final class WeightGoalViewModel {
    // Profil pengguna input sebelumnya
    var currentWeightKg: Double = 60.0
    var heightCm: Double = 168.0

    // Target berat badan yang diatur lewat slider
    var targetWeightKg: Double = 56.0 {
        didSet {
            handleWeightChange()
        }
    }

    // Batasan rentang slider
    let minSliderWeight: Double = 40.0
    let maxSliderWeight: Double = 90.0

    // Trigger haptik untuk view
    var triggerCategoryHaptic: Bool = false
    var triggerTickHaptic: Bool = false

    // State internal kategori sebelumnya untuk deteksi perubahan
    private var previousCategory: GoalCategory = .cutting

    // Evaluasi ilmiah dinamis
    var insight: ScientificGoalInsight {
        ScientificWeightEngine.evaluate(
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            heightCm: heightCm
        )
    }

    var activeCategory: GoalCategory {
        insight.category
    }

    init(currentWeightKg: Double = 60.0, targetWeightKg: Double = 56.0, heightCm: Double = 168.0) {
        self.currentWeightKg = currentWeightKg
        self.targetWeightKg = targetWeightKg
        self.heightCm = heightCm
        self.previousCategory = ScientificWeightEngine.evaluate(
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            heightCm: heightCm
        ).category
    }

    /// Menangani perubahan berat badan saat slider bergeser
    private func handleWeightChange() {
        let newCategory = insight.category
        if newCategory != previousCategory {
            previousCategory = newCategory
            triggerCategoryHaptic.toggle()
        }
    }

    /// Memilih kategori tujuan secara langsung (misal saat tap pill)
    func selectCategory(_ category: GoalCategory) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            switch category {
            case .cutting:
                targetWeightKg = max(minSliderWeight, currentWeightKg - 4.0)
            case .maintaining:
                targetWeightKg = currentWeightKg
            case .bulking:
                targetWeightKg = min(maxSliderWeight, currentWeightKg + 4.0)
            }
        }
    }
}
