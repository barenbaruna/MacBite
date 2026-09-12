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
    and macronutrient progress against their personal targets, write ONE short \
    coaching insight about their next meal.

    STRICT LENGTH LIMIT: at most 2 short sentences, total. Never write a third \
    sentence. Do not list all the numbers back — a natural, conversational \
    line is preferred over a robotic report of raw figures.

    Rules:
    - If the calorie target is already met or exceeded, congratulate them —
      do not suggest eating more.
    - If a macro is notably behind its target (e.g. protein far below target
      while calories are on track), you may call it out specifically.
    - If they're close to their calorie limit, suggest a lighter next meal.
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
            // sampling: .greedy — same determinism convention as the other
            // two generators in this app (FoundationModelFoodNamer,
            // FoundationModelNutritionEstimator).
            let response = try await session.respond(
                to: prompt,
                options: GenerationOptions(sampling: .greedy)
            )
            return Self.clamp(toSentences: Self.maxSentences, response.content)
        } catch {
            throw AppError.inferenceFailed("Foundation Model failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Prompt Building

    private func buildPrompt(for summary: DailySummary) -> String {
        """
        Today's progress:
        - Calories: \(summary.consumedCalories)/\(summary.targetCalories) kcal \
        (\(summary.remainingCalories) kcal remaining)
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
