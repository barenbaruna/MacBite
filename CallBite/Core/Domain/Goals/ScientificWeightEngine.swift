//
//  ScientificWeightEngine.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Scientific evaluation insights for the user's weight goal.
struct ScientificGoalInsight: Equatable {
    let category: GoalCategory
    let deltaKg: Double
    let weeklyRateKg: Double
    let estimatedWeeks: Int
    let dailyCalorieAdjustment: Double
    let headline: String
    let subtitle: String
    let macroAdvice: String
    let metabolicNote: String
    let isSafeWHO: Bool
    let idealRangeText: String
}

/// Scientific computation engine for weight target evaluation and bounds.
enum ScientificWeightEngine {
    /// Healthy adult weight range (BMI 18.5 - 24.9 kg/m2) per WHO standards.
    static func healthyWeightRange(heightCm: Double) -> ClosedRange<Double> {
        let heightM = max(1.0, heightCm / 100.0)
        let minWeight = 18.5 * (heightM * heightM)
        let maxWeight = 24.9 * (heightM * heightM)
        return minWeight...maxWeight
    }

    /// Evaluates weight goal trajectory against current weight and height.
    static func evaluate(
        currentWeightKg: Double,
        targetWeightKg: Double,
        heightCm: Double = 168.0
    ) -> ScientificGoalInsight {
        let delta = targetWeightKg - currentWeightKg
        let absDelta = abs(delta)
        let healthyRange = healthyWeightRange(heightCm: heightCm)
        let isSafe = healthyRange.contains(targetWeightKg)

        let rangeMinFormatted = String(format: "%.1f", healthyRange.lowerBound)
        let rangeMaxFormatted = String(format: "%.1f", healthyRange.upperBound)
        let idealRangeStr = "\(rangeMinFormatted) – \(rangeMaxFormatted) kg"

        if delta < -0.5 {
            return makeCuttingInsight(delta: delta, absDelta: absDelta, isSafe: isSafe, idealRangeStr: idealRangeStr)
        } else if delta > 0.5 {
            return makeBulkingInsight(delta: delta, absDelta: absDelta, isSafe: isSafe, idealRangeStr: idealRangeStr)
        } else {
            return makeMaintainingInsight(isSafe: isSafe, idealRangeStr: idealRangeStr)
        }
    }

    private static func makeCuttingInsight(
        delta: Double,
        absDelta: Double,
        isSafe: Bool,
        idealRangeStr: String
    ) -> ScientificGoalInsight {
        let weeklyRate = 0.50
        let weeks = max(1, Int(ceil(absDelta / weeklyRate)))
        let headline = isSafe ? "Let’s Set Your Target" : "Target Perhatian"
        let subtitle = isSafe
            ? "This is a safe and realistic weight goal that can bring meaningful health benefits."
            : "Target ini berada di bawah batas BMI sehat WHO (\(idealRangeStr))."

        return ScientificGoalInsight(
            category: .cutting,
            deltaKg: delta,
            weeklyRateKg: weeklyRate,
            estimatedWeeks: weeks,
            dailyCalorieAdjustment: -500.0,
            headline: headline,
            subtitle: subtitle,
            macroAdvice: "Prioritaskan protein 1.8–2.2g/kg BB untuk menjaga massa otot saat defisit kalori.",
            metabolicNote: "Defisit moderat 500 kkal mencegah penurunan laju metabolik istirahat.",
            isSafeWHO: isSafe,
            idealRangeText: idealRangeStr
        )
    }

    private static func makeMaintainingInsight(isSafe: Bool, idealRangeStr: String) -> ScientificGoalInsight {
        let headline = "Let’s Set Your Target"
        let subtitle = "This is a safe and realistic weight goal that can bring meaningful health benefits."

        return ScientificGoalInsight(
            category: .maintaining,
            deltaKg: 0.0,
            weeklyRateKg: 0.0,
            estimatedWeeks: 0,
            dailyCalorieAdjustment: 0.0,
            headline: headline,
            subtitle: subtitle,
            macroAdvice: "Konsumsi kalori seimbang (TDEE) dengan pembagian makronutrisi seimbang 45C/25P/30F.",
            metabolicNote: "Fase maintain mengoptimalkan pemulihan sistem hormon dan kekuatan latihan beban.",
            isSafeWHO: isSafe,
            idealRangeText: idealRangeStr
        )
    }

    private static func makeBulkingInsight(
        delta: Double,
        absDelta: Double,
        isSafe: Bool,
        idealRangeStr: String
    ) -> ScientificGoalInsight {
        let weeklyRate = 0.28
        let weeks = max(1, Int(ceil(absDelta / weeklyRate)))
        let headline = isSafe ? "Let’s Set Your Target" : "Evaluasi Massa Otot"
        let subtitle = isSafe
            ? "This is a safe and realistic weight goal that can bring meaningful health benefits."
            : "Target ini di atas batas normal BMI WHO (\(idealRangeStr))."

        return ScientificGoalInsight(
            category: .bulking,
            deltaKg: delta,
            weeklyRateKg: weeklyRate,
            estimatedWeeks: weeks,
            dailyCalorieAdjustment: 300.0,
            headline: headline,
            subtitle: subtitle,
            macroAdvice: "Dukung surplus 300 kkal dengan karbohidrat kompleks sebelum dan setelah latihan.",
            metabolicNote: "Surplus terkontrol memaksimalkan sintesis protein otot murni tanpa lemak berlebih.",
            isSafeWHO: isSafe,
            idealRangeText: idealRangeStr
        )
    }
}
