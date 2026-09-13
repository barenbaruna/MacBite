//
//  FoundationModelInsightGenerator.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 12/09/26.
//
//  Generates a short coaching message from the day's calorie/macro progress
//  using Apple's on-device Foundation Model. Plain-text generation (no
//  @Generable schema needed — just a short sentence, not structured data).
//

import Foundation
import FoundationModels

public final class FoundationModelInsightGenerator: InsightGenerating, @unchecked Sendable {

    // MARK: - Tuning

    /// Hard ceiling enforced in code, on top of the instruction below — the
    /// model is asked for at most 2 sentences, but this guards against a
    /// verbose response slipping through by truncating at the 2nd sentence
    /// boundary. Keeps the dashboard's insight line compact regardless.
    private static let maxSentences = 2

    // MARK: - Availability

    /// Whether Apple Intelligence / Foundation Models is actually usable on
    /// this device right now. CallBite's deployment target is already iOS
    /// 26.5, so no `@available` compile-time guard is needed — this is a
    /// runtime check only (device eligibility / Apple Intelligence toggle).
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // MARK: - Session

    private static let instructions = """
    You are a friendly, concise nutrition coach. Given a user's daily calorie \
    and macronutrient progress against their personal targets, write a short \
    coaching insight about their next meal in EXACTLY 2 sentences, structured \
    like this:

    1. A very short opener (3-5 words only, like a quick exclamation) — vary
       your wording every time instead of reusing the same phrase. Draw from
       a wide range of styles, e.g. "Nice progress!", "Keep it going!",
       "Almost there!", "Solid effort today!", "Right on track!", "Good
       pace!", "Halfway there!", "Great choices today!" — or invent similarly
       short, varied phrasing that fits the specific situation below. NOT a
       full description of what they achieved.
    2. ONE sentence with the actual actionable insight or detail.

    Example of the right length: "Nice progress! You still have some room
    for a balanced dinner." NOT: "You're doing fantastic with your
    macronutrient goals today, keep up the great work and consider a
    balanced dinner." — that second version is too long for the opener.

    STRICT LENGTH LIMIT: EXACTLY 2 sentences, total, and the FIRST one must \
    stay under 5 words. Never write a third sentence. Do not list all the \
    numbers back — a natural, conversational line is preferred over a \
    robotic report of raw figures.

    You will be given how many calories are REMAINING or, if the user has
    gone OVER their target, exactly how many calories OVER. Pay close
    attention to which one it is and by how much — a small overage and a
    large overage call for different tones:

    Rules:
    - If calories are OVER target: do NOT suggest eating more food, no
      matter how far behind a macronutrient is. If the overage is small,
      reassure them it's not a big deal. If it's large, stay supportive and
      non-judgmental — suggest going lighter or drinking water for the rest
      of the day, never a specific dish to eat next.
    - If calories are exactly at or essentially at target (very few kcal
      remaining), congratulate them and do not suggest more food either.
    - If there is a meaningful amount of calories remaining: this is the
      only case where you may suggest what kind of next meal fits — and you
      may call out a macronutrient that's notably behind its target (e.g.
      protein far below target) if a meal choice could help close that gap.
    - Keep it warm and practical — no medical advice, no guilt-tripping.
    """

    private let session: LanguageModelSession

    public init() {
        session = LanguageModelSession(instructions: Self.instructions)
    }

    // MARK: - InsightGenerating

    public func generateInsight(for summary: DailySummary) async throws -> String {
        guard Self.isAvailable else {
            throw AppError.modelNotFound("Foundation Models (Apple Intelligence)")
        }

        let prompt = buildPrompt(for: summary)

        do {
            // Deliberately NOT sampling: .greedy here, unlike the other two
            // generators (FoundationModelFoodNamer, FoundationModelNutritionEstimator).
            // Greedy is right for THOSE because a numeric estimate should be
            // consistent for the same input. This generator writes a short
            // coaching message — greedy made the SAME day's numbers always
            // produce the exact same opener, which felt robotic/repetitive
            // (found via real testing). Random sampling gives natural variety
            // across calls while `temperature` keeps it from wandering too far.
            let response = try await session.respond(
                to: prompt,
                options: GenerationOptions(sampling: .random(probabilityThreshold: 0.9), temperature: 1.0)
            )
            return Self.clamp(toSentences: Self.maxSentences, response.content)
        } catch {
            throw AppError.inferenceFailed("Foundation Model failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Prompt Building

    private func buildPrompt(for summary: DailySummary) -> String {
        // `DailySummary.remainingCalories` clamps at 0, so it can't tell the
        // model HOW FAR over budget the user is once they've exceeded their
        // target — compute the real signed balance here instead so an
        // overage of 50 kcal and one of 800 kcal aren't indistinguishable.
        let calorieBalanceLine: String
        let overage = summary.consumedCalories - summary.targetCalories
        if overage > 0 {
            calorieBalanceLine = "\(overage) kcal OVER target"
        } else {
            calorieBalanceLine = "\(summary.remainingCalories) kcal remaining"
        }

        return """
        Today's progress:
        - Calories: \(summary.consumedCalories)/\(summary.targetCalories) kcal consumed (\(calorieBalanceLine))
        - Protein: \(summary.totalProtein)/\(summary.targetProtein) g
        - Carbs: \(summary.totalCarbs)/\(summary.targetCarbs) g
        - Fat: \(summary.totalFat)/\(summary.targetFat) g
        - Fiber: \(summary.totalFiber)/\(summary.targetFiber) g

        Give ONE short, encouraging, actionable insight (at most 2 sentences) \
        about what to eat next.
        """
    }

    // MARK: - Defensive Truncation

    /// Keeps at most `count` sentences from `text`, in case the model ignores
    /// the length instruction. Splits on ". "/"! "/"? " boundaries — good
    /// enough for short coaching sentences, not meant to be a full NLP
    /// sentence tokenizer.
    private static func clamp(toSentences count: Int, _ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        var sentences: [String] = []
        var current = ""
        for character in trimmed {
            current.append(character)
            if ".!?".contains(character) {
                sentences.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
                if sentences.count == count { break }
            }
        }

        if sentences.isEmpty {
            return trimmed
        }
        return sentences.joined(separator: " ")
    }
}
